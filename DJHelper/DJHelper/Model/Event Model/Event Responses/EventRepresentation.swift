//
//  EventRepresentation.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/1/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation
struct EventRepresentation: Codable {
    let name: String
    let eventType: String
    let eventDescription: String
    let eventDate: Date
    let hostID: Int32
    let locationID: Int32
    var startTime: Date?
    var endTime: Date?
    var imageURL: URL?
    var notes: String?
    var eventID: Int32?
    
    enum EventRepresentationCodingKeys: String, CodingKey {
        case name
        case eventType = "event_type"
        case eventDescription = "description"
        case eventDate = "date"
        case hostID = "dj_id"
        case locationID = "location_id"
        case startTime = "start_time"
        case endTime = "end_time"
        case imageURL = "img_url"
        case notes
        case eventID = "id"
    }
    
    init(name: String, eventType: String, eventDescription: String, eventDate: Date, hostID: Int32, locationID: Int32, startTime: Date? = nil, endTime: Date? = nil, imageURL: URL? = nil, notes: String? = nil, eventID: Int32? = nil){
        self.name = name
        self.eventType = eventType
        self.eventDescription = eventDescription
        self.eventDate = eventDate
        self.hostID = hostID
        self.locationID = locationID
    }
    
    //MARK: - CODABLE INITAILIZERS
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: EventRepresentationCodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        eventType = try container.decode(String.self, forKey: .eventType)
        eventDescription = try container.decode(String.self, forKey: .eventDescription)
        eventDate = try container.decode(Date.self, forKey: .eventDate)
        hostID = try container.decode(Int32.self, forKey: .hostID)
        locationID = try container.decode(Int32.self, forKey: .locationID)
        startTime = try container.decode(Date?.self, forKey: .startTime)
        endTime = try container.decode(Date?.self, forKey: .endTime)
        imageURL = try container.decode(URL?.self, forKey: .imageURL)
        notes = try container.decode(String?.self, forKey: .notes)
        eventID = try container.decode(Int32.self, forKey: .eventID)
    }
    
    func encode(with encoder: Encoder) throws {
        var container = encoder.container(keyedBy: EventRepresentationCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(eventType, forKey: .eventType)
        try container.encode(eventDescription, forKey: .eventDescription)
        try container.encode(eventDate, forKey: .eventDate)
        try container.encode(hostID, forKey: .hostID)
        try container.encode(locationID, forKey: .locationID)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(notes, forKey: .notes)
        try container.encode(eventID, forKey: .eventID)
    }
}
