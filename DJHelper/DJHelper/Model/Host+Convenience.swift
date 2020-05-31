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
    
    //MARK: - CODABLE INITAILIZERS
    
    
    //MARK: - CONVENIENCE INITIALIZERS
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
    
    //HostRepresentation -> Host
    convenience init?(hostRepresnetation: HostRepresentation, context: NSManagedObjectContext = CoreDataStack.shared.mainContext){
        self.init(name: hostRepresnetation.name, username: hostRepresnetation.username, email: hostRepresnetation.email, password: hostRepresnetation.password, bio: hostRepresnetation.bio, identifier: hostRepresnetation.identifier, phone: hostRepresnetation.phone, profilePic: hostRepresnetation.profilePic, website: hostRepresnetation.website)
    }
  
    //Host -> HostRepresentation
    var hostToHostRep: HostRepresentation? {
        guard let name = self.name,
            let username = self.username,
            let password = self.password,
            let email = self.email,
            let phone = self.phone,
            let website = self.website,
            let bio = self.bio,
            let pic = self.profilePic else { return nil }
        
        return HostRepresentation(name: name, username: username, password: password, email: email, phone: phone, website: website, bio: bio, profilePic: pic, identifier: self.identifier)
    }
}
