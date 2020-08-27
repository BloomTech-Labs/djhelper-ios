//
//  DJHelperTests.swift
//  DJHelperTests
//
//  Created by Craig Swanson on 6/2/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import XCTest
import CoreData
@testable import DJHelper

class DJHelperTests: XCTestCase {

    // DONE Log in with a known existing host should not return error
    // DONE Log in with a non-existing host should return an error: 401 response
    // TRANSFER TO UI TEST Register with different password fields should return nothing (UI alert controller appears)
    // DONE Register with an existing username should return an error: 409 response
    // TRANSFER TO UI TEST Register with empty text field should return nothing
    // DONE Register with a unique username and matching passwords should not return an error
    // TRANSFER TO UI TEST ...and continuing to sign in should not return an error.

    func testNetworkCallValidLogIn() {
        let hostController = HostController()

        let testHost = Host(username: "BMac3", email: "bmac@funkybunch.com", password: "ciao", identifier: 64)

        let hostLoginExpectation = expectation(description: "Wait for log in to complete")

        hostController.logIn(with: testHost) { (result) in
            hostLoginExpectation.fulfill()

            switch result {
            case let .success(hostRegistrationResponse):
                XCTAssertNotNil(hostRegistrationResponse)
                XCTAssertEqual(hostRegistrationResponse.username, "BMac3")
            case let .failure(error):
                XCTAssertNil(error)
            }
        }
        wait(for: [hostLoginExpectation], timeout: 3)
    }

    func testNetworkCallInvalidLogIn() {
        let hostController = HostController()

        let testHost = Host(username: "BMaco", email: "bmac@funkybunch.com", password: "ciao", identifier: 64)

        let hostLoginExpectation = expectation(description: "Wait for log in to complete")

        hostController.logIn(with: testHost) { (result) in
            hostLoginExpectation.fulfill()

            switch result {
            case let .success(response):
                XCTAssertNil(response)
            case let .failure(error):
                XCTAssertNotNil(error)
            }
        }
        wait(for: [hostLoginExpectation], timeout: 3)
    }

    func testRegisterWithExistingUsername() {
        let hostController = HostController()

        let testHost = Host(username: "BMac", email: "bmac@funkybunch.com", password: "ciao", identifier: 64)

        let duplicateRegistrationExpectation = expectation(description: "Wait for registration response")

        hostController.registerHost(with: testHost) { (result) in
            duplicateRegistrationExpectation.fulfill()

            switch result {
            case let .success(response):
                XCTAssertNil(response)
            case let .failure(error):
                XCTAssertNotNil(error)
            }
        }
        wait(for: [duplicateRegistrationExpectation], timeout: 3)
    }

    func testRegisterValidNewUser() {
        let hostController = HostController()

        let testHost = Host(username: "BMac2", email: "bmac@funkybunch.com", password: "ciao", identifier: 999)

        let validRegistrationExpectation = expectation(description: "Wait for registration response")

        hostController.registerHost(with: testHost) { (result) in
            validRegistrationExpectation.fulfill()

            switch result {
            case let .success(response):
                XCTAssertNotNil(response)
                XCTAssertEqual(response.email, "bmac@funkybunch.com")
                XCTAssert(response.identifier < Int32(999))
            case let .failure(error):
                XCTAssertNil(error)
            }
        }
        wait(for: [validRegistrationExpectation], timeout: 3)
    }
}

class MockLoader: NetworkDataLoader {

    var data: Data?
    var error: Error?
    var response: URLResponse?

    func loadData(from request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void) {
        DispatchQueue.global().async {
            completion(self.data, self.response, self.error)
        }
    }

    func loadData(from url: URL, completion: @escaping (Data?, Error?) -> Void) {
        DispatchQueue.global().async {
            completion(self.data, self.error)
        }
    }
}

// MARK: - Mock Data
/*
 INPUT Bethany MacDonald BMac bmac@funkybunch.com ciao
 http response = 201
 */
let validNewHostRegistrationResponse = """
{
  "id": 64,
  "username": "BMac",
  "name": "Bethany MacDonald",
  "email": "bmac@funkybunch.com",
  "phone": null,
  "website": null,
  "bio": null,
  "profile_pic_url": null
}
""".data(using: .utf8)!

/*
 INPUT BMac ciao
 http response = 200
 */
let validUserLogInResponse = """
{
  "id": 64,
  "username": "BMac",
  "name": "Bethany MacDonald",
  "email": "bmac@funkybunch.com",
  "phone": null,
  "website": null,
  "bio": null,
  "profile_pic_url": null,
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjY0LCJ1c2VybmFtZSI6IkJNYWMiLCJpYXQiOjE1OTEyMTU2OTYsImV4cCI6MTU5MTMwMjA5Nn0.QBWBHHljvp9Ky86hSsuPMAQmHKOWTZoZ-8wEIp8UuN8"
}
""".data(using: .utf8)
