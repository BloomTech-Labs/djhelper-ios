//
//  HostLogin.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/1/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

    // Used for the DJLoginVC to register a new host (sent to backend)
struct HostLogin: Codable {
    let username: String
    let password: String
}
