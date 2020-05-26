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
    
    enum CodingKeys: String, CodingKey {
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
}
