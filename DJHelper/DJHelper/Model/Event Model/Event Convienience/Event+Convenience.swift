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
    convenience init(name: String, eventType: String, eventDescription: String, eventDate: Date, hostID: Int32, locationID: Int32, startTime: Date, endTime: Date, imageURL: URL, notes: String, eventID: Int32, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
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
}
