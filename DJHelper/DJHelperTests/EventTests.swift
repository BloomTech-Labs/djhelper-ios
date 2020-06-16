//
//  EventTests.swift
//  DJHelperTests
//
//  Created by Craig Swanson on 6/15/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import XCTest
import CoreData
@testable import DJHelper

class EventTests: XCTestCase {

    /*
     Creating a new event with valid inputs does not give error
     Creating a new event with valid inputs adds one element to the event array
     Creating a new event with invalid inputs results in an error
     Deleting an event does not result in error
     Deleting an event reduces the event array count by one
     Updating an event with valid inputs does not give error
     Updating an event with invalid inputs results in an error
     */

    func testValidNewEvent() {
        let eventController = EventController()

        let testHost = Host(username: "lulu", email: "lulu@me.com", password: "bully", identifier: 28)

        let testEventDate = Date()

        let validNewEvent = Event(name: "UnitTest",
                                  eventType: "UnitTest",
                                  eventDescription: "Testing Valid Event Creation",
                                  eventDate: testEventDate,
                                  hostID: testHost.identifier,
                                  eventID: nil)

        let createEventExpectation = expectation(description: "Wait for event to be created")

        eventController.authorize(event: validNewEvent) { (results) in
            createEventExpectation.fulfill()

            switch results {

            case let .success(newEventResponse):
                XCTAssertNotNil(newEventResponse)
                XCTAssertEqual(newEventResponse.eventType, "UnitTest")
            case let .failure(error):
                XCTAssertNil(error)
            }
        }
        wait(for: [createEventExpectation], timeout: 3)
    }
}
