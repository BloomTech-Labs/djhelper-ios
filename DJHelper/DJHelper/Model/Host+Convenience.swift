//
//  Host+Convenience.swift
//  DJHelper
//
//  Created by Craig Swanson on 5/26/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation
import CoreData

extension Host {

    enum CodingKeys: String, CodingKey {
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
    
    convenience init (name: String, username: String, email: String, password: String, bio: String, identifier: Int32, phone: String, profilePic: URL, website: URL, context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.name = name
        self.username = username
        self.email = email
        self.password = password
        self.bio = bio
        self.identifier = identifier
        self.phone = phone
        self.profilePic = profilePic
        self.website = website
    }
    
}
