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
    let eventDescription: String
    let eventDate: Date
    let hostID: Int32
    var imageURL: URL?
    var notes: String?

    enum CodingKeys: String, CodingKey {
        case name
        case eventType = "event_type"
        case eventDescription = "description"
        case eventDate = "date"
        case hostID = "dj_id"
        case imageURL = "img_url"
        case notes
}

    init(name: String,
         eventType: String,
         eventDescription: String,
         eventDate: Date,
         hostID: Int32,
         imageURL: URL? = nil,
         notes: String? = nil) {
        self.name = name
        self.eventType = eventType
        self.eventDescription = eventDescription
        self.eventDate = eventDate
        self.hostID = hostID
        self.imageURL = imageURL
        self.notes = notes
    }

    // MARK: - CODABLE INITAILIZERS
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        eventType = try container.decode(String.self, forKey: .eventType)
        eventDescription = try container.decode(String.self, forKey: .eventDescription)
        eventDate = try container.decode(Date.self, forKey: .eventDate)
        hostID = try container.decode(Int32.self, forKey: .hostID)
        imageURL = try container.decode(URL?.self, forKey: .imageURL)
        notes = try container.decode(String?.self, forKey: .notes)
    }

    func encode(with encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(eventType, forKey: .eventType)
        try container.encode(eventDescription, forKey: .eventDescription)
        try container.encode(eventDate, forKey: .eventDate)
        try container.encode(hostID, forKey: .hostID)
        try container.encode(imageURL, forKey: .imageURL)
        try container.encode(notes, forKey: .notes)
    }
}
