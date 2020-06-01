//
//  HostLoginResponse.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/1/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

struct HostLoginResponse: Codable {
    var name: String
    var username: String
    var password: String?
    var email: String
    var phone: String?
    var website: URL?
    var bio: String?
    var profilePic: URL?
    var identifier: Int32
    var token: String
    
    enum HostLoginResponseCodingKeys: String, CodingKey {
        case username
        case name
        case password
        case email
        case phone
        case website
        case bio
        case profilePic = "profile_pic_url"
        case identifier = "id"
        case token
    }
    
    init(name: String, username: String, email: String, password: String? = nil, phone: String? = nil, website: URL? = nil, bio: String? = nil, profilePic: URL? = nil, identifier: Int32, token: String){
        self.name = name
        self.username = username
        self.email = email
        self.identifier =  identifier
        self.password = password
        self.token = token
    }
    
    //    MARK: - CODABLE INITAILIZERS
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: HostLoginResponseCodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        username = try container.decode(String.self, forKey: .username)
        password = try container.decode(String?.self, forKey: .password)
        email = try container.decode(String.self, forKey: .email)
        phone = try container.decode(String?.self, forKey: .phone)
        website = try container.decode(URL?.self, forKey: .website)
        bio = try container.decode(String?.self, forKey: .bio)
        profilePic = try container.decode(URL?.self, forKey: .profilePic)
        identifier = try container.decode(Int32.self, forKey: .identifier)
        token = try container.decode(String.self, forKey: .token)
    }
    
    func encode(with encoder: Encoder) throws {
        var container = encoder.container(keyedBy: HostLoginResponseCodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(username, forKey: .username)
        try container.encode(password, forKey: .password)
        try container.encode(email, forKey: .email)
        try container.encode(phone, forKey: .phone)
        try container.encode(website, forKey: .website)
        try container.encode(bio, forKey: .bio)
        try container.encode(profilePic, forKey: .profilePic)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(token, forKey: .token)
    }
}
