//
//  TrackResponse.swift
//  DJHelper
//
//  Created by Michael Flowers on 8/11/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

// Struct is for when the dj wants to see which songs/tracks guests have requested and to add a request to the playlist and delete song from playlist
/*  Example pasted below:
 {
   "id": 3,
   "spotify_id": "4v7SAP4KD96BFLWiCd1vF0",
   "name": "Madonna",
   "artist_name": "Drake",
   "url": "https://open.spotify.com/track/4v7SAP4KD96BFLWiCd1vF0",
   "isExplicit": true,
   "preview": "http://bit.ly/2nXRRfX",
   "img": "https://i.scdn.co/image/ab67616d00001e022090f4f6cc406e6d3c306733",
   "event_id": 51
 }
 */
struct TrackResponse: Codable {
    var trackId: Int32
    var spotifyId: String
    var songName: String
    var artist: String
    var externalURL: URL
    var isExplicit: Bool
    var preview: String
    var image: URL
    var eventId: Int
    var votes: String?

    enum CodingKeys: String, CodingKey {
        case trackId = "id"
        case spotifyId = "spotify_id"
        case songName = "name"
        case artist = "artist_name"
        case externalURL = "url"
        case isExplicit
        case preview
        case image = "img"
        case eventId = "event_id"
        case votes
    }

    init(trackId: Int32,
         spotifyId: String,
         songName: String,
         artist: String,
         externalURL: URL,
         isExplicit: Bool,
         preview: String,
         image: URL,
         eventId: Int,
         votes: String? = "0") { // We do not have logic for upvoting yet, so it defaults to 0

        self.trackId = trackId
        self.spotifyId = spotifyId
        self.songName = songName
        self.artist = artist
        self.externalURL = externalURL
        self.isExplicit = isExplicit
        self.preview = preview
        self.image = image
        self.eventId = eventId
        self.votes = votes
    }

    // MARK: - CODABLE INITIALIZERS

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        trackId = try container.decode(Int32.self, forKey: .trackId)
        spotifyId = try container.decode(String.self, forKey: .spotifyId)
        songName = try container.decode(String.self, forKey: .songName)
        artist = try container.decode(String.self, forKey: .artist)
        externalURL = try container.decode(URL.self, forKey: .externalURL)
        isExplicit = try container.decode(Bool.self, forKey: .isExplicit)
        preview = try container.decode(String.self, forKey: .preview)
        image = try container.decode(URL.self, forKey: .image)
        eventId = try container.decode(Int.self, forKey: .eventId)
        votes = try container.decode(String.self, forKey: .votes)
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
        try container.encode(votes, forKey: .votes)
    }
}
