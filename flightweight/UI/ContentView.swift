//
//  ContentView.swift
//  lightweight
//
//  Created by Eric Lightfoot on 2021-02-04.
//

import SwiftUI
import RealmSwift
import Combine

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @State var isPresenting: Bool = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button("Log out") {
                    appState.LOG_OUT {

                    }
                }
                        .padding()
                        .disabled(!canLogOut)
            }
            Text("Hello, world!")
                    .padding()
                    .sheet(isPresented: $isPresenting) {
                        LoginView(isPresented: $isPresenting).environmentObject(appState)
                    }
            Button("Show Login Screen") {
                self.isPresenting = true
            }
        }
    }

    var canLogOut: Bool {
        appState.can(.LOG_OUT, target: nil)
    }
}

struct LoginView: View {
    @EnvironmentObject var appState: AppState

    @Binding var isPresented: Bool

    @State private var email: String = ""
    @State private var pwd: String = ""

    var body: some View {
        VStack {
            TextField("Email", text: $email)
            TextField("Password", text: $pwd)
        }
                .padding()
        HStack {
            Button("Log In") {
                appState.LOGIN_WITH_EMAIL_CREDENTIALS(email: email, pwd: pwd) {
                    self.isPresented = false
                }
            }
            Spacer().frame(width: 80)
            Button("Sign Up") {
                appState.SIGN_UP(email: email, pwd: pwd) {
                    self.isPresented = false
                }
            }
                .disabled(appState.authState.isAuthenticated)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
