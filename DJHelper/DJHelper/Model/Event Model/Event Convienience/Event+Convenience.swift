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
                     eventType: String,
                     eventDescription: String,
                     eventDate: Date,
                     hostID: Int32,
                     locationID: Int32,
                     startTime: Date,
                     endTime: Date,
                     imageURL: URL,
                     notes: String,
                     eventID: Int32,
                     context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        self.init(context: context)
        self.name = name
        self.eventType = eventType
        self.eventDescription = eventDescription
        self.eventDate = eventDate
        self.hostID = hostID
        self.locationID = locationID
        self.startTime = startTime
        self.endTime = endTime
        self.imageURL = imageURL
        self.notes = notes
        self.eventID = eventID
    }
    
    //EventRepresentation -> Event
    convenience init?(eventRepresentation: EventRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        guard let startTime = eventRepresentation.startTime,
            let endTime = eventRepresentation.endTime,
            let imageURL = eventRepresentation.imageURL,
            let notes = eventRepresentation.notes,
            let convertedDate = eventRepresentation.eventDate.dateFromString(),
            let eventID = eventRepresentation.eventID else { return nil }
        
        self.init(name: eventRepresentation.name,
                  eventType: eventRepresentation.eventType,
                  eventDescription: eventRepresentation.eventDescription,
                  eventDate: convertedDate,
                  hostID: eventRepresentation.hostID,
                  locationID: eventRepresentation.locationID,
                  startTime: startTime,
                  endTime: endTime,
                  imageURL: imageURL,
                  notes: notes,
                  eventID: eventID)
    }
    
    //Event -> EventRepresentation
    var eventAuthorizationRep: EventRepresentation? {
        guard let name = self.name,
            let eventType = self.eventType,
            let description = self.eventDescription,
            let eventDate = self.eventDate else { return nil }
        
        return EventRepresentation(name: name,
                                   eventType: eventType,
                                   eventDescription: description,
                                   eventDate: eventDate.stringFromDate(),
                                   hostID: self.hostID,
                                   locationID: self.locationID,
                                   eventID: self.eventID)
    }
    
    //Event -> EventAuthRequest
    var eventAuthRequest: EventAuthRequest? {
        guard let name = self.name,
             let eventType = self.eventType,
             let description = self.eventDescription,
             let eventDate = self.eventDate else { return nil }
        
        return EventAuthRequest(name: name, eventType: eventType, description: description, date: eventDate, djId: self.hostID, locationId: self.locationID)
    }
}
