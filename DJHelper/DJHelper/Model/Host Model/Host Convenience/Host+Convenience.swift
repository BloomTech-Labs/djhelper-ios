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

    // MARK: - CONVENIENCE INITIALIZERS
    convenience init (name: String? = "temp",
                      username: String,
                      email: String,
                      password: String,
                      bio: String? = "",
                      identifier: Int32?,
                      phone: String? = "",
                      profilePic: URL? = nil,
                      website: URL? = nil,
                      context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.init(context: context)
        self.name = name
        self.username = username
        self.email = email
        self.password = password
        self.bio = bio
        self.identifier = identifier ?? 0
        self.phone = phone
        self.profilePic = profilePic
        self.website = website
    }

    //HostRepresentation -> Host
    @discardableResult
    convenience init?(hostRepresnetation: HostRepresentation,
                      context: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        guard let bio = hostRepresnetation.bio,
            let identifier = hostRepresnetation.identifier,
            let phone = hostRepresnetation.phone,
            let pic = hostRepresnetation.profilePic,
            let website = hostRepresnetation.website else { return nil }

        self.init(name: hostRepresnetation.name,
                  username: hostRepresnetation.username,
                  email: hostRepresnetation.email,
                  password: hostRepresnetation.password,
                  bio: bio,
                  identifier: identifier,
                  phone: phone,
                  profilePic: pic,
                  website: website)
    }

    var hostLogin: HostLogin? {
        guard let username = self.username,
            let password = self.password else { return nil }
        return HostLogin(username: username, password: password)
    }

    var hostRegistration: HostRegistration? {
        guard let name = self.name,
            let username = self.username,
            let email = self.email,
            let password = self.password else { return nil }

        return HostRegistration(name: name, username: username, email: email, password: password)
    }

    var hostUpdate: HostUpdate? {
        guard let name = self.name,
            let username = self.username,
            let email = self.email else { return nil }

        return HostUpdate(name: name,
                          username: username,
                          email: email,
                          phone: self.phone,
                          bio: self.bio,
                          website: self.website?.absoluteString,
                          profilePicUrl: self.profilePic?.absoluteString)
    }

    //Host -> HostRepresentation
    var hostToHostRep: HostRepresentation? {
        guard let name = self.name,
            let username = self.username,
            let password = self.password,
            let email = self.email else { return nil }
//            let phone = self.phone,
//            let website = self.website,
//            let bio = self.bio,
//            let pic = self.profilePic else { return nil }

        return HostRepresentation(name: name,
                                  username: username,
                                  email: email,
                                  password: password,
                                  phone: phone,
                                  website: website,
                                  bio: bio,
                                  profilePic: self.profilePic,
                                  identifier: self.identifier)
    }
}
