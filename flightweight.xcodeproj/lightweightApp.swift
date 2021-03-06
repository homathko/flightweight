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
