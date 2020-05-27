//
//  HostController.swift
//  DJHelper
//
//  Created by Craig Swanson on 5/26/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit
import CoreData

class HostController {
    
    private let baseURL = URL(string: "https://api.dj-helper.com/api")!
    var bearer: Bearer?

    let dataLoader: NetworkDataLoader

    init(dataLoader: NetworkDataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    // MARK: - Register New Host
    // the server returns the host properties along with the generated ID
    func registerHost(with host: Host, completion: @escaping (Result<Host, Error>) -> Void) {

    }

    // MARK: - Log In Existing Host
    // the server returns the host properties along with the generated bearer token
    func logIn(with host: Host, completion: @escaping (Error?) -> Void) {

    }

    // MARK: - Update Existing Host
    // server does not presently have a PUT update for host(DJ)

    // MARK: - Delete Host
    // server does not presently have a DEL for host(DJ)
}
