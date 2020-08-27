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
    convenience init (name: String? = "",
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
        guard let identifier = hostRepresnetation.identifier else { return nil }
        if hostRepresnetation.website == "" {

        }

        self.init(name: hostRepresnetation.name,
                  username: hostRepresnetation.username,
                  email: hostRepresnetation.email,
                  password: hostRepresnetation.password,
                  bio: hostRepresnetation.bio,
                  identifier: identifier,
                  phone: hostRepresnetation.phone,
                  profilePic: URL(string: hostRepresnetation.profilePic ?? ""),
                  website: URL(string: hostRepresnetation.website ?? ""))
    }

    // Used for the HostLoginVC to log in an existing host
    var hostLogin: HostLogin? {
        guard let username = self.username,
            let password = self.password else { return nil }
        return HostLogin(username: username, password: password)
    }

    // Used for the HostRegistrationVC to register a new host
    var hostRegistration: HostRegistration? {
        guard let name = self.name,
            let username = self.username,
            let email = self.email,
            let password = self.password else { return nil }

        return HostRegistration(name: name, username: username, email: email, password: password)
    }

    // Used for the HostProfileVC to update the host profile
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

        return HostRepresentation(name: name,
                                  username: username,
                                  email: email,
                                  password: password,
                                  phone: self.phone,
                                  website: website?.absoluteString,
                                  bio: self.bio,
                                  profilePic: self.profilePic?.absoluteString,
                                  identifier: self.identifier)
    }
}
