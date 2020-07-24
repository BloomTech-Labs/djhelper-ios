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
    let isExplicit: Bool
    let eventDescription: String
    let eventDate: Date
    let hostID: Int32
    var imageURL: URL?

    enum CodingKeys: String, CodingKey {
        case name
        case isExplicit
        case eventDescription = "notes"
        case eventDate = "date"
        case hostID = "dj_id"
        case imageURL = "img_url"
}

    init(name: String,
         isExplicit: Bool,
         eventDescription: String,
         eventDate: Date,
         hostID: Int32,
         imageURL: URL? = nil) {
        self.name = name
        self.isExplicit = isExplicit
        self.eventDescription = eventDescription
        self.eventDate = eventDate
        self.hostID = hostID
        self.imageURL = imageURL
    }

    // MARK: - CODABLE INITAILIZERS
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        isExplicit = try container.decode(Bool.self, forKey: .isExplicit)
        eventDescription = try container.decode(String.self, forKey: .eventDescription)
        eventDate = try container.decode(Date.self, forKey: .eventDate)
        hostID = try container.decode(Int32.self, forKey: .hostID)
        imageURL = try container.decode(URL?.self, forKey: .imageURL)
    }

    func encode(with encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(isExplicit, forKey: .isExplicit)
        try container.encode(eventDescription, forKey: .eventDescription)
        try container.encode(eventDate, forKey: .eventDate)
        try container.encode(hostID, forKey: .hostID)
        try container.encode(imageURL, forKey: .imageURL)
    }
}
