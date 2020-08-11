//
//  TrackResponse.swift
//  DJHelper
//
//  Created by Michael Flowers on 8/11/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

struct TrackResponse: Codable {
    var trackId: Int
    var spotifyId: String
    var songName: String
    var artist: String
    var externalURL: URL
    var isExplicit: Bool
    var preview: String
    var image: URL
    var eventId: Int
    
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
    
    init(trackId: Int, spotifyId: String, songName: String, artist: String, externalURL: URL, isExplicit: Bool, preview: String, image: URL, eventId: Int) {
        self.trackId = trackId
        self.spotifyId = spotifyId
        self.songName = songName
        self.artist = artist
        self.externalURL = externalURL
        self.isExplicit = isExplicit
        self.preview = preview
        self.image = image
        self.eventId = eventId
    }
    
    //MARK: - CODABLE INITIALIZERS
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trackId = try container.decode(Int.self, forKey: .trackId)
        spotifyId = try container.decode(String.self, forKey: .spotifyId)
        songName = try container.decode(String.self, forKey: .songName)
        artist = try container.decode(String.self, forKey: .artist)
        externalURL = try container.decode(URL.self, forKey: .externalURL)
        isExplicit = try container.decode(Bool.self, forKey: .isExplicit)
        preview = try container.decode(String.self, forKey: .preview)
        image = try container.decode(URL.self, forKey: .image)
        eventId = try container.decode(Int.self, forKey: .eventId)
    }
    
    func encode(with encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(trackId, forKey: .trackId)
        try container.encode(spotifyId, forKey: .spotifyId)
        try container.encode(songName, forKey: .songName)
        try container.encode(artist, forKey: .artist)
        try container.encode(externalURL, forKey: .externalURL)
        try container.encode(isExplicit, forKey: .isExplicit)
        try container.encode(preview, forKey: .preview)
        try container.encode(image, forKey: .image)
        try container.encode(eventId, forKey: .eventId)
    }
}
