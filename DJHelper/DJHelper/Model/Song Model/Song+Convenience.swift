//
//  Song+Convenience.swift
//  DJHelper
//
//  Created by Craig Swanson on 7/9/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation
import CoreData

extension Song {

    enum CodingKeys: String, CodingKey {
        case artist = "artist_name"
        case explicit
        case externalURL = "external_urls"
        case inSetList
        case songID = "id"
        case songName = "song_name"
        case upVotes
        case voted
    }

    var songRepresentation: SongRepresentation? {
        guard let artist = artist,
            let songName = songName else { return nil }
        return SongRepresentation(artist: artist,
                                  explicit: explicit,
                                  externalURL: (externalURL ?? URL(string: ""))!,
                                  songID: Int(songID),
                                  songName: songName)
    }

    @discardableResult convenience init(artist: String,
                                        explicit: Bool = true,
                                        externalURL: URL,
                                        inSetList: Bool = false,
                                        songID: Int?,
                                        songName: String,
                                        upVotes: Int = 0,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
    self.init(context: context)
    self.artist = artist
        self.explicit = explicit
        self.externalURL = externalURL
    self.inSetList = inSetList
    self.songID = Int32(songID ?? 0)
    self.songName = songName
    self.upVotes = Int32(upVotes)
    }

    @discardableResult convenience init?(songRepresentation: SongRepresentation,
                                         context: NSManagedObjectContext) {

        self.init(artist: songRepresentation.artist,
                  explicit: songRepresentation.explicit,
                  externalURL: songRepresentation.externalURL,
                  songID: songRepresentation.songID,
                  songName: songRepresentation.songName)
    }
}
