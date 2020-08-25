//
//  SongRepresentation.swift
//  DJHelper
//
//  Created by Craig Swanson on 7/9/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

// Used in searching for songs
struct TrackRepresentation: Codable {

    enum CodingKeys: String, CodingKey {
        case artist = "artist_name"
        case explicit
        case externalURL = "external_urls"
        case songId = "id"
        case songName = "song_name"
        case preview
        case image
    }

    var artist: String
    var explicit: Bool
    var externalURL: URL
    var songId: String
    var songName: String
    var preview: String?
    var image: URL?
}
