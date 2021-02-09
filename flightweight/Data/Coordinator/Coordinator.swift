//
// Created by Eric Lightfoot on 2021-02-05.
//

import Foundation
import Combine
import RealmSwift
import GameplayKit

enum CoordinatorState: Equatable {
    case initialized
    case running
    case failed

    func should (transitionTo nextState: CoordinatorState) -> Bool {
        switch self {
            case .initialized:
                if case CoordinatorState.running = nextState { return true }
            case .running:
                if case CoordinatorState.initialized = nextState { return true } else
                if case CoordinatorState.failed = nextState { return true }
            case .failed:
                if case CoordinatorState.initialized = nextState { return true } else
                if case CoordinatorState.running = nextState { return true }
        }

        return false
    }

    func onEnter () {
        switch self {
            case .initialized: ()
            case .running: ()
            case .failed: ()
        }
    }

    func onExit () {
        switch self {
            case .initialized: ()
            case .running: ()
            case .failed: ()
        }
    }
}

class Coordinator {
    private var state: CoordinatorState = .initialized
    var cancellables = Set<AnyCancellable>()
    private var authStateCancellable: AnyCancellable?

    init (app: AppState) {
        authStateCancellable = app.authState.$state.sink { authState in
            switch authState {
                case .none:
                    self.setState(.initialized)
                case .anonymous(let user):
                    self.reset(user: user)
                case .authenticated(let user):
                    self.reset(user: user)
            }
        }
    }

    private func setState(_ state: CoordinatorState) {
        if self.state.should(transitionTo: state) {
            self.state.onExit()
            self.state = state
            self.state.onEnter()
        }
    }

    func run (withEnsuredUser: User) { }

    func reset (user: User) {
        for cancellable in cancellables {
            cancellable.cancel()
        }
        setState(.initialized)

        /// If this coordinator can work with anonymous credentials alone, restart
        run(withEnsuredUser: user)
    }

    func fail () { }

    func retry (user: User) {
        for cancellable in cancellables {
            cancellable.cancel()
        }
        self.run(withEnsuredUser: user)
    }

    func terminate () {
        for cancellable in cancellables {
            cancellable.cancel()
        }

        /// Should allow deinit
        authStateCancellable = nil
    }

    deinit {
        print("Deinitializing \(String(describing: self))")
    }
}
