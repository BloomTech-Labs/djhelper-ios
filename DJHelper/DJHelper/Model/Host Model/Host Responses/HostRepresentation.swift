//
//  HostRepresentation.swift
//  DJHelper
//
//  Created by Michael Flowers on 5/31/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

struct HostRepresentation: Codable {
    var name: String?
    var username: String
    var password: String
    var email: String
    var phone: String?
    var website: String?
    var bio: String?
    var profilePic: String?
    var identifier: Int32?

    enum HostCodingKeys: String, CodingKey {
        case username
        case name
        case password
        case email
        case phone
        case website
        case bio
        case profilePic = "profile_pic_url"
        case identifier = "id"
    }

    init(name: String?,
         username: String,
         email: String,
         password: String,
         phone: String? = nil,
         website: String? = nil,
         bio: String? = nil,
         profilePic: String? = nil,
         identifier: Int32? = nil) {
        self.name = name
        self.username = username
        self.email = email
        self.password = password
        // adding the rest
        self.phone = phone
        self.website = website
        self.bio = bio
        self.profilePic = profilePic
        self.identifier = identifier
    }

    // MARK: - CODABLE INITAILIZERS
     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: HostCodingKeys.self)
        name = try container.decode(String?.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        password = try container.decode(String.self, forKey: .password)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decode(String?.self, forKey: .phone)
        website = try container.decode(String?.self, forKey: .website)
        bio = try container.decode(String?.self, forKey: .bio)
        profilePic = try container.decode(String?.self, forKey: .profilePic)
        identifier = try container.decode(Int32.self, forKey: .identifier)
    }

    func encode(with encoder: Encoder) throws {
        var container = encoder.container(keyedBy: HostCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
        try container.encode(website, forKey: .website)
        try container.encode(bio, forKey: .bio)
        try container.encode(profilePic, forKey: .profilePic)
        try container.encode(identifier, forKey: .identifier)
    }
}
