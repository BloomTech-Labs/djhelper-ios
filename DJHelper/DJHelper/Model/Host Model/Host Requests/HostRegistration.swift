//
//  HostRegistration.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/1/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

    // Used for the DJRegisterVC to register a new host (sent to backend)
struct HostRegistration: Codable {
    let name: String
    let username: String
    let email: String
    let password: String
}
