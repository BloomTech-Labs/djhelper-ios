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
     DONE Creating a new event with valid inputs does not give error
     DONE Creating a new event with valid inputs adds one element to the event array
     MOVE TO UI TEST Creating a new event with invalid inputs results in an error
     MOVE TO UI TEST Deleting an event does not result in error
     DONE Deleting an event reduces the event array count by one
     DONE Updating an event with valid inputs does not give error
     MOVE TO UI TEST Updating an event with invalid inputs results in an error
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

    func testValidEventUpdate() {

        /*
         The idea for this test is to:
         1. Create a new event and post it to the server
         2. Verify the post was successful (as in a previous test)
         3. Update that new event by changing one of its properties
         4. Call the update method
         5. Verify that the event now has the updated data
         */

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
                validNewEvent.eventID = newEventResponse.eventID!
            case let .failure(error):
                XCTAssertNil(error)
            }
        }
        wait(for: [createEventExpectation], timeout: 3)

        // this updatedEvent object changes the contents of eventType property
        let updatedEvent = eventController.updateEvent(event: validNewEvent,
                                                       eventName: "UnitTest",
                                                       eventDate: Date(),
                                                       description: "Testing Valid Event Creation",
                                                       type: "UnitTest Update",
                                                       notes: "Testing Update")

        let updateEventExpectaton = expectation(description: "Wait for event to be updated"
        )
        eventController.saveUpdateEvent(updatedEvent) { (results) in
            updateEventExpectaton.fulfill()

            switch results {
            case .success: break
            case let .failure(error):
                XCTAssertNil(error)
            }
        }
        wait(for: [updateEventExpectaton], timeout: 3)

        // Fetch event created previously by using its eventID and verify eventType was updated
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        let hostPredicate = NSPredicate(format: "eventID == %i", validNewEvent.eventID)
        fetchRequest.predicate = hostPredicate
        var fetchedEvents: [Event]?

        let moc = CoreDataStack.shared.mainContext
        moc.performAndWait {
            fetchedEvents = try? fetchRequest.execute()
        }

        let verifyUpdatedEvent = fetchedEvents?.first
        XCTAssertEqual(verifyUpdatedEvent?.eventType, "UnitTest Update")
    }
}
