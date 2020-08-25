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

    ///Convert Song into TrackResponse so that we can make network calls with it
    var songToTrackResponse: TrackResponse? {
        guard let spotifyId = songId,
        let songName = songName,
        let artist = artist,
        let externalURL = externalURL,
        let preview = preview,
        let image = image
        else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return nil
        }

        return TrackResponse(trackId: songID,
                             spotifyId: spotifyId,
                             songName: songName,
                             artist: artist,
                             externalURL: externalURL,
                             isExplicit: explicit,
                             preview: preview,
                             image: image,
                             eventId: Int(event?.eventID ?? 0),
                             votes: String(upVotes))
    }

    var songRepresentation: TrackRepresentation? {
        guard let artist = artist,
            let songName = songName else { return nil }
        return TrackRepresentation(artist: artist,
                                  explicit: explicit,
                                  externalURL: (externalURL ?? URL(string: ""))!,
                                  songId: songId ?? "",
                                  songName: songName)
    }

    //convert song into a trackRequest to send to backend - this happens when the user taps the add button in the cells
    var songToTrackRequest: TrackRequest? {
        guard let songId = songId,
        let artist = artist,
        let songName = songName,
        let externalURL = externalURL,
        let preview = preview,
        let image = image
        else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return nil
        }
        return TrackRequest(spotifyId: songId,
                            songName: songName,
                            artist: artist,
                            externalURL: externalURL,
                            isExplicit: explicit,
                            preview: preview,
                            image: image,
                            eventId: event?.eventID ?? 0) // it will originally default to 0 but we add the eventID later
    }

    @discardableResult convenience init(artist: String,
                                        explicit: Bool = true,
                                        externalURL: URL,
                                        inSetList: Bool = false,
                                        songId: String?,
                                        songName: String,
                                        upVotes: Int = 0,
                                        preview: String?,
                                        image: URL?,
                                        songID: Int32 = 0,
                                        context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.artist = artist
        self.explicit = explicit
        self.externalURL = externalURL
        self.inSetList = inSetList
        self.songId = songId
        self.songName = songName
        self.upVotes = Int32(upVotes)
        self.preview = preview
        self.image = image
        self.songID = songID
    }

    //TrackRep -> Song
    @discardableResult convenience init?(songRepresentation: TrackRepresentation,
                                         context: NSManagedObjectContext) {

        self.init(artist: songRepresentation.artist,
                  explicit: songRepresentation.explicit,
                  externalURL: songRepresentation.externalURL,
                  songId: songRepresentation.songId,
                  songName: songRepresentation.songName,
                  preview: songRepresentation.preview,
                  image: songRepresentation.image)
    }

}
