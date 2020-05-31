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
    //MARK: - HOST ERRORS
    enum HostErrors: Error {
        case registrationError(Error)
        case unknownError(Error)
        case loginError(Error)
        case noDataError
    }
    
    typealias HostHandler = (Result<Host, HostErrors>) -> Void
    
    private let baseURL = URL(string: "https://api.dj-helper.com/api")!
    var bearer: Bearer?
    
    let dataLoader: NetworkDataLoader

    init(dataLoader: NetworkDataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    // MARK: - Register New Host
    // the server returns the host properties along with the generated ID
    func registerHost(with host: Host, completion: @escaping (Result<Host, HostErrors>) -> Void) {
        //take the host and turn in into a hr
        guard let hostRep = host.hostToHostRep else { return }
        
        //create url
        let registrationURL = baseURL.appendingPathComponent("register").appendingPathComponent("dj")
        
        //create url request method
        var urlRequest = URLRequest(url: registrationURL)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        
        //pass data into httpBody
        do {
            urlRequest.httpBody = try JSONEncoder().encode(hostRep)
        } catch  {
            print("Error encoding HostRepresentation on line: \(#line) in function: \(#function)\n Readable error: \(error.localizedDescription)\n Technical error: \(error)")
        }
        
        //urlsession.shared.dataTask
        dataLoader.loadData(from: urlRequest) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("HTTPResponse: \(response.statusCode) in function: \(#function)")
            }
            
            if let error = error {
                print("Error: \(error.localizedDescription) on line \(#line) in function: \(#function)\n Technical error: \(error)")
                completion(.failure(.registrationError(error)))
            }
            
            guard let data = data else {
                completion(.failure(.noDataError))
                return
            }
            
            do {
                let hostRepresentation = try JSONDecoder().decode(HostRepresentation.self, from: data)
                guard let host = Host(hostRepresnetation: hostRepresentation) else { completion(.failure(.noDataError)); return }
                completion(.success(host))
            } catch {
                 print("Error on line: \(#line) in function: \(#function)\n Readable error: \(error.localizedDescription)\n Technical error: \(error)")
                completion(.failure(.unknownError(error)))
            }
        }
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
