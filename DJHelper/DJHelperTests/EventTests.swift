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

    func testNewEventInCoreData() {
        let eventController = EventController()

        let testHost = Host(username: "lulu", email: "lulu@me.com", password: "bully", identifier: 28)
        let testEventDate = Date()

        // here create an array of events using an NSFetchRequest and a predicate with the host.identifier
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        let hostPredicate = NSPredicate(format: "hostID == %i", testHost.identifier)
        fetchRequest.predicate = hostPredicate
        var fetchedEvents: [Event]?

        let moc = CoreDataStack.shared.mainContext
        moc.performAndWait {
            fetchedEvents = try? fetchRequest.execute()
        }

        let beforeCount: Int = fetchedEvents!.count

        let validNewEvent = Event(name: "UnitTest",
                                  eventType: "UnitTest",
                                  eventDescription: "Testing Valid Event Creation",
                                  eventDate: testEventDate,
                                  hostID: testHost.identifier,
                                  eventID: nil)

        let createEventExpectation = expectation(description: "Wait for event to be created")

        eventController.authorize(event: validNewEvent) { (_) in
            createEventExpectation.fulfill()
        }
        wait(for: [createEventExpectation], timeout: 3)

        moc.performAndWait {
            fetchedEvents = try? fetchRequest.execute()
        }

        let afterCount: Int = fetchedEvents!.count

        XCTAssertTrue(afterCount == (beforeCount + 1))
    }

    func testDeleteEvent() {
        let eventController = EventController()

        // Properties for test event
        let testHost = Host(username: "lulu", email: "lulu@me.com", password: "bully", identifier: 28)
        let testEventDate = Date()
        let testEvent: Event?

        // Properties for fetch request
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        let hostPredicate = NSPredicate(format: "hostID == %i", testHost.identifier)
        fetchRequest.predicate = hostPredicate
        var fetchedEvents: [Event]?
        var beforeCount: Int?
        var afterCount: Int?

        // Create and save test event to core data and web server
        testEvent = Event(name: "UnitTestDelete",
                                  eventType: "UnitTest",
                                  eventDescription: "Testing Valid Event Creation",
                                  eventDate: testEventDate,
                                  hostID: testHost.identifier,
                                  eventID: nil)

        let createEventExpectation = expectation(description: "Wait for event to be created")

        eventController.authorize(event: testEvent!) { (result) in
            createEventExpectation.fulfill()

            switch result {
            case .success: break
            case .failure:
                XCTFail("Authorize new event unexpectedly failed")
            }
        }
        wait(for: [createEventExpectation], timeout: 3)

        let moc = CoreDataStack.shared.mainContext
        moc.performAndWait {
            fetchedEvents = try? fetchRequest.execute()
        }
        beforeCount = fetchedEvents?.count

        // Delete the event that was just created
        eventController.deleteEvent(for: testEvent!)
        sleep(2)

        moc.performAndWait {
            fetchedEvents = try? fetchRequest.execute()
        }

        afterCount = fetchedEvents!.count

        XCTAssertTrue(afterCount == (beforeCount! - 1))
    }
}
