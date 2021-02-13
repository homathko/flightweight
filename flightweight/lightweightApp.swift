//
//  lightweightApp.swift
//  lightweight
//
//  Created by Eric Lightfoot on 2021-02-04.
//

import SwiftUI
import Combine
import RealmSwift


class AppDelegate: NSObject, UIApplicationDelegate {
    let appState = AppState()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let role = Role()

        if let user = appState.app.currentUser {
            let target = DataTarget<Role>(domain: .user("12345"), location: .user, id: role.id, user)
        } else {
            appState.LOGIN_WITH_EMAIL_CREDENTIALS(email: "a@a.ca", pwd: "pqpqpq") {
                guard let user = self.appState.app.currentUser else {
                    fatalError("")
                }

                self.appState.authState.login(authenticatedUser: user)
            }
        }
        return true
    }
}

@main
struct lightweightApp: SwiftUI.App {
    @Environment(\.scenePhase) private var scenePhase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(appDelegate.appState)
        }
    }
}
