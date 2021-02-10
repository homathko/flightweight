//
//  SPMDepsTestApp.swift
//  SPMDepsTest
//
//  Created by Eric Lightfoot on 2021-02-02.
//

import SwiftUI
import Combine
import RealmSwift

enum NetworkError: Error {
    case loginError(Error)
    case registerError(Error)
    case logoutError(Error)
}


class AppState: ObservableObject {
    var app: RealmSwift.App
    var userToken: NSKeyValueObservation? = nil
    @Published var authState = AuthStateController()
    var roleController: RoleCoordinator! = nil

    @Published var error: Error? = nil

    var cancellables = Set<AnyCancellable>()

    init () {
        /// This is a realm app
        app = .init(id: "login-flow-jjfpx")
        /// Simulate having an ongoing system coordinator
        /// It has to handle having no currentUser, changes in auth level
        roleController = RoleCoordinator(appState: self)
        /// Listen for changes to the roles, as they will affect what
        /// actions are available in the UI
        roleController.$roles.receive(on: DispatchQueue.main).sink { roles in
            self.objectWillChange.send()
        } .store(in: &cancellables)

        if let user = app.currentUser {
            /// User is already identified as anonymous or email credentialed
            if user.identities.count > 1 {
                authState.login(authenticatedUser: user)
            } else {
                authState.start(anonymousUser: user)
            }

            logLoginStateChange(user: user)
        } else {
            app.login(credentials: .anonymous) { result in
                switch result {
                    case .failure(let err):
                        self.setNetworkError(.loginError(err))
                        self.authState.failToNoUser(withError: err)
                    case .success(let user):
                        self.authState.start(anonymousUser: user)
                        self.logLoginStateChange(user: user)

                        // Store new anonymous role for this user TODO Move to cloud function
                        self.roleController.addAnonymousRole(user: user)
                }
            }
        }
    }

    func SIGN_UP (email: String, pwd: String, _ completion: @escaping () -> ()) {
        app.emailPasswordAuth.registerUser(email: email, password: pwd) { err in
            guard err == nil else {
                self.setNetworkError(.registerError(err!))
                return completion()
            }
            /// Link new identity with current user
            self.app.currentUser?.linkUser(credentials: .emailPassword(email: email, password: pwd)) { result in
                switch result {
                    case .failure(let err):
                        self.authState.fail(toAnonymousUser: self.app.currentUser!, withError: err)
                        self.setNetworkError(.registerError(err))
                    case .success(let user):
                        self.authState.login(authenticatedUser: user)
                        self.logLoginStateChange(user: user)
                        // Upgrade to registered user role TODO Move to cloud function
                        self.roleController.upgradeToRegisteredUserRole(user: user)
                }

                return completion()
            }
        }
    }
    
    func LOGIN_WITH_EMAIL_CREDENTIALS (email: String, pwd: String, _ completion: @escaping () -> ()) {
        app.login(credentials: .emailPassword(email: email, password: pwd)) { result in
            switch result {
                case .failure(let err):
                    if let user = self.app.currentUser {
                        self.authState.fail(toAnonymousUser: user, withError: err)
                    } else {
                        self.authState.failToNoUser(withError: err)
                    }
                    self.setNetworkError(.logoutError(err))
                case .success(let user):
                    self.authState.login(authenticatedUser: user)
                    self.logLoginStateChange(user: user)
            }

            return completion()
        }
    }

    func LOG_OUT (_ completion: @escaping () -> ()) {
        print("LOG_OUT action executing")
        app.currentUser?.logOut { err in
            guard err == nil else {
                self.authState.fail(toAnonymousUser: self.app.currentUser!, withError: err!)
                self.setNetworkError(.loginError(err!))
                return completion()
            }

            self.authState.logout()

            /// Support anonymous credentialed users
            self.app.login(credentials: .anonymous) { result in
                switch result {
                    case .failure(let err):
                        self.authState.failToNoUser(withError: err)
                        self.setNetworkError(.loginError(err))
                    case .success(let user):
                        self.authState.start(anonymousUser: user)
                        self.logLoginStateChange(user: user)

                        // Store new anonymous role for this user TODO Move to cloud function
                        self.roleController.addAnonymousRole(user: user)
                }

                return completion()
            }
        }
    }
}

extension AppState {
    func setNetworkError (_ error: NetworkError) {
        DispatchQueue.main.async {
            self.error = error
        }
        if let user = app.currentUser {
            logLoginStateChange(user: user)
        }

        print("Error: \(error.localizedDescription)")
    }

    func logLoginStateChange (user: User) {
        let count = user.identities.count
        print("Logged in with \(count) identities")
        print("\(user.identities.map { $0.providerType })")
    }
}
