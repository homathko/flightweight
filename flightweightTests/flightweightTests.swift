//
//  flightweightTests.swift
//  flightweightTests
//
//  Created by Eric Lightfoot on 2021-02-05.
//

import XCTest
@testable import flightweight

class flightweightTests: XCTestCase {
    let app = AppState()

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let target = DataTarget<Role>(domain: .user("dhhiuuwdwdygwdw"), location: .user, id: "18hydbiuyb3fd093")
        print(target.path.encoded)
    }

}
