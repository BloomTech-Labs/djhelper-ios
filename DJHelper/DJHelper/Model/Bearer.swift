//
//  Bearer.swift
//  DJHelper
//
//  Created by Craig Swanson on 5/26/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

// used to get the authorization token from the server

class Bearer: Codable {
    static let shared = Bearer()

    var token: String?
}
