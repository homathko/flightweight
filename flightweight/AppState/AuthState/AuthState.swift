//
// Created by Eric Lightfoot on 2021-02-08.
//

import Foundation
import RealmSwift

enum AuthState: Equatable {
    case none
    case anonymous(User)
    case authenticated(User)

    func should (transitionTo nextState: AuthState) -> Bool {
        switch self {
            case .none:
                if case AuthState.anonymous(_) = nextState { return true } else
                if case AuthState.authenticated(_) = nextState { return true }
            case .anonymous(_):
                if case AuthState.none = nextState { return true } else
                if case AuthState.authenticated(_) = nextState { return true }
            case .authenticated(_):
                if case AuthState.none = nextState { return true }
        }

        return false
    }

    func onEnter () -> User? {
        switch self {
            case .none: return nil
            case .anonymous(let user): return user
            case .authenticated(let user): return user
        }
    }

    static func ==(lhs: AuthState, rhs: AuthState) -> Bool {
        switch (lhs, rhs) {
            case (.anonymous, .anonymous):
                return sameUser(lhs, rhs)
            case (.authenticated, .authenticated):
                return sameUser(lhs, rhs)
            case (.none, .none):
                return true
            default: return false
        }
    }

    static func sameUser (_ lhs: AuthState, _ rhs: AuthState) -> Bool {
        if case .none = lhs {
            if case .none = rhs {
                return true
            } else {
                return false
            }
        } else if case .anonymous(let userL) = lhs {
            if case .anonymous(let userR) = rhs {
                return userL === userR
            }
        } else if case .authenticated(let userL) = lhs {
            if case .authenticated(let userR) = rhs {
                return userL === userR
            }
        } else {
            return false
        }

        return false
    }
}

class AuthStateController: ObservableObject {
    @Published var state: AuthState = .none
    @Published var user: User? = nil

    func setState (_ state: AuthState) {
        if self.state.should(transitionTo: state) {
            self.state = state
            user = self.state.onEnter()
        }
    }

    var isAuthenticated: Bool {
        if case .authenticated(_) = state { return true }
        return false
    }

    var isAnonymous: Bool {
        if case .anonymous(_) = state { return true }
        return false
    }

    var isNone: Bool {
        self.state == .none
    }

    func start (anonymousUser user: User) {
        setState(.anonymous(user))
    }

    func login (authenticatedUser user: User) {
        setState(.authenticated(user))
    }

    func fail (toAnonymousUser user: User, withError error: Error) {
        setState(.anonymous(user))
    }

    func failToNoUser (withError error: Error) {
        setState(.none)
    }

    func logout () {
        setState(.none)
    }
}