//
//  TrackResponse.swift
//  DJHelper
//
//  Created by Michael Flowers on 8/11/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

struct TrackResponse: Codable {

    enum CodingKeys: String, CodingKey {
        case trackId = "id"
        case spotifyId = "spotify_id"
        case songName = "name"
        case artist = "artist_name"
        case externalURL = "external_urls"
        case isExplicit
        case preview
        case image = "img"
        case eventId = "event_id"
    }

    var trackId: Int
    var spotifyId: String
    var songName: String
    var artist: String
    var externalURL: URL
    var isExplicit: Bool
    var preview: String
    var image: URL
    var eventId: Int
}
