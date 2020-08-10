//
//  Playlist.swift
//  DJHelper
//
//  Created by Michael Flowers on 8/10/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

struct Playlist {
    let id: Int
    //if we have problems maybe change it to eventId.
    let eventID: Int
    let songID: Int
    let queueNum: Int
    
    //because the backend uses snake case
    enum PlaylistCodingKeys: String, CodingKey {
        case id
        case eventID = "event_id"
        case songID = "song_id"
        case queueNum = "queue_num"
    }
    
    init(id: Int, eventID: Int, songID: Int, queueNum: Int) {
        self.id = id
        self.eventID = eventID
        self.songID = songID
        self.queueNum = queueNum
    }
    
    // MARK: - Codable Initializers
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: PlaylistCodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        eventID = try container.decode(Int.self, forKey: .eventID)
        songID = try container.decode(Int.self, forKey: .songID)
        queueNum = try container.decode(Int.self, forKey: .queueNum)
    }
    
    func encode(with encoder: Encoder) throws {
        var container = encoder.container(keyedBy: PlaylistCodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(eventID, forKey: .eventID)
        try container.encode(songID, forKey: .songID)
        try container.encode(queueNum, forKey: .queueNum)
    }
}
