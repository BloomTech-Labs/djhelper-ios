//
//  Event+Convenience.swift
//  DJHelper
//
//  Created by Craig Swanson on 5/26/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation
import CoreData

extension Event {

    @discardableResult
    convenience init(name: String,
                     isExplicit: Bool = true,
                     eventDescription: String?,
                     eventDate: Date,
                     hostID: Int32,
                     imageURL: URL? = nil,
                     eventID: Int32?,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {

        self.init(context: context)
        self.name = name
        self.isExplicit = isExplicit
        self.eventDescription = eventDescription
        self.eventDate = eventDate
        self.hostID = hostID
        self.imageURL = imageURL
        if let unwrappedEventID = eventID {
            self.eventID = unwrappedEventID
        }
    }

    // EventRepresentation -> Event
    convenience init?(eventRepresentation: EventRepresentation,
                      context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let eventDateFromString = eventRepresentation.eventDate.dateFromString() else { return nil }

        self.init(name: eventRepresentation.name,
                  isExplicit: eventRepresentation.isExplicit,
                  eventDescription: eventRepresentation.eventDescription,
                  eventDate: eventDateFromString,
                  hostID: eventRepresentation.hostID,
                  imageURL: eventRepresentation.imageURL,
                  eventID: eventRepresentation.eventID)
    }

    // Event -> EventRepresentation
    var eventAuthorizationRep: EventRepresentation? {
        guard let name = self.name,
            let eventDate = self.eventDate else { return nil }

        return EventRepresentation(name: name,
                                   isExplicit: self.isExplicit,
                                   eventDescription: self.eventDescription,
                                   eventDate: eventDate.jsonStringFromDate(),
                                   hostID: self.hostID,
                                   imageURL: self.imageURL,
                                   eventID: self.eventID)
    }

    // Event -> EventAuthRequest
    var eventAuthRequest: EventAuthRequest? {
        guard let name = self.name,
             let eventDate = self.eventDate else { return nil }

        return EventAuthRequest(name: name,
                                isExplicit: self.isExplicit,
                                eventDescription: self.eventDescription ?? "",
                                eventDate: eventDate,
                                hostID: self.hostID,
                                imageURL: self.imageURL)
    }
}
