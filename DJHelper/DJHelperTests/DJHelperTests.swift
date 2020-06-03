//
//  DJHelperTests.swift
//  DJHelperTests
//
//  Created by Craig Swanson on 6/2/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import XCTest
@testable import DJHelper

class DJHelperTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    // Log in with a known existing host should not return error
    // Log in with a non-existing host should return an error
    // Register with different password fields should return and error
    // Register with an existing username should return an error
    // Register with empty text field should return nothing
    // Register with a unique username and matching passwords should not return an error
    // ...and continuing to sign in should not return an error.
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
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
