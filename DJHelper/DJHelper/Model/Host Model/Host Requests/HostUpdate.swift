//
//  HostUpdate.swift
//  DJHelper
//
//  Created by Craig Swanson on 6/10/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

    // Used for the HostProfileVC to register a new host (sent to backend)
struct HostUpdate: Codable {
    let name: String
    let username: String
    let email: String
    let phone: String?
    let bio: String?
    let website: String?
    let profilePicUrl: String?
}
