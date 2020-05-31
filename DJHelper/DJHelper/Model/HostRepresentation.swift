//
//  HostRepresentation.swift
//  DJHelper
//
//  Created by Michael Flowers on 5/31/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

struct HostRepresentation: Codable {
    var name: String
    var username: String
    var password: String
    var email: String
    var phone: String
    var website: URL
    var bio: String
    var profilePic: String
    let identifier: String
}
