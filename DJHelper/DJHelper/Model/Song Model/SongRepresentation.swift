//
//  SongRepresentation.swift
//  DJHelper
//
//  Created by Craig Swanson on 7/9/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

struct SongRepresentation: Codable {
    var artist: String
    var explicit: Bool
    var externalURL: URL
    var songID: Int
    var songName: String
}
