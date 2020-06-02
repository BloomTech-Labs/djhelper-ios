//
//  EventAuthRequest.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/1/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

struct EventAuthRequest: Codable {
    let name: String
    let eventType: String
    let description: String
    let date: Date
    let djId: Int32
    let locationId: Int32
    var startTime: Date?
    var endTime: Date?
    var imageUrl: URL?
    var notes: String?
    var eventId: Int32?
    
    init(name: String,
         eventType: String,
         description: String,
         date: Date,
         djId: Int32,
         locationId: Int32,
         startTime: Date? = nil,
         endTime: Date? = nil,
         imageUrl: URL? = nil,
         notes: String? = nil,
         eventId: Int32? = nil) {
        self.name = name
        self.eventType = eventType
        self.description = description
        self.date = date
        self.djId = djId
        self.locationId = locationId
    }
}
