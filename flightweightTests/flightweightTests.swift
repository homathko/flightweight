//
//  flightweightTests.swift
//  flightweightTests
//
//  Created by Eric Lightfoot on 2021-02-05.
//

import XCTest
import Combine
@testable import flightweight

class flightweightTests: XCTestCase {
    var appState = AppState()
    var cancellables = Set<AnyCancellable>()
    var expectation = XCTestExpectation()

    override class func setUp() {
        if appState.authenticatedUser() == nil {
            appState.LOG_IN_WITH_EMAIL_CREDENTIALS(email: "a@a.ca", pwd: "pqpqpq")
        }
    }
    
    override func tearDown () {
        wait(for: [expectation], timeout: 30.0)
        super.tearDown()
    }

    func testCreate () throws {
        let role = Role()
        let target = DataTarget<Role>(domain: .global, location: .directory, appState.authenticatedUser()!)
        Interactor(target).create(role)
            .sink {
                dump($0)
            }
    }

    func testGetOnce () {
        
    }
}

protocol Entity {
    var value: Int { get }
}

protocol ViewModel {
    associatedtype T
    var item: T { get }
    
    var description: String { get }
}

struct TestObject: Entity {
    var value: Int
}

struct TestObjectViewModel: ViewModel {
    var item: TestObject
    var description: String {
        String(format: "%@", "\(item)")
    }
}

protocol ViewModelPublisher {
    associatedtype V: ViewModel
    func viewModel (for item: Entity) -> AnyPublisher<V, Never>
}

struct TestViewModelBuilder<V: ViewModel>: ViewModelPublisher {
    func viewModel(for item: Entity) -> AnyPublisher<V, Never> {
        
    }
}

func delayedOneShotBlock (s: TimeInterval, completion: @escaping () -> ()) {
    Timer.scheduledTimer(withTimeInterval: s, repeats: false) { timer in
        timer.invalidate()
        completion()
    }
}
