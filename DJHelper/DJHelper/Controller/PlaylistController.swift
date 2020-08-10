//
//  PlaylistController.swift
//  DJHelper
//
//  Created by Michael Flowers on 8/10/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

enum PlaylistError: Error {
     case authorizationError(Error)
       case noDataError
       case encodeError(Error)
       case decodeError(Error)
       case noPlaylistOnServer(Error)
       case otherError(Error)
}

class PlaylistController {
    
}
