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

    // MARK: - NETWORK ERRORS
    enum HostErrors: Error {
        case registrationError(Error)
        case unknownError(Error)
        case loginError(Error)
        case noAuthorization
        case noDataError
    }

    typealias HostHandler = (Result<Host, HostErrors>) -> Void

    private let baseURL = URL(string: "https://dj-helper-be.herokuapp.com/api")!
//    var bearer: Bearer?

    let dataLoader: NetworkDataLoader

    init(dataLoader: NetworkDataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    // MARK: - Fetch Host

    /**
     This method makes a network call to fetch a Host object from the server and completes with a Host object or HostErrors Enum
    
     - Parameter Id: To be used to append the url to identify the specific Host on the server
     - Parameter completion: Completes with Host object or HostErrors Enum.
     */

    func fetchHostFromServer(with Id: Int32,
                             completion: @escaping (Result<Host, HostErrors>) -> Void) {

        let url = baseURL.appendingPathComponent("dj")
            let finalURL = url.appendingPathComponent("\(Id)")
            let urlRequest = URLRequest(url: finalURL)

            dataLoader.loadData(from: urlRequest) { (data, response, error) in
                if let response = response as? HTTPURLResponse {
                    print("HTTPResponse: \(response.statusCode) in function: \(#function)")
                }

                if let error = error {
                    print("""
                        Error: \(error.localizedDescription) on line \(#line)
                        in function: \(#function)\n Technical error: \(error)
                        """)
                    completion(.failure(.unknownError(error)))
                }

                guard let data = data else {
                    print("Error on line: \(#line) in function: \(#function)")
                    completion(.failure(.noDataError))
                    return
                }

                let decoder = JSONDecoder()

                do {
    //                let printableData = String(data: data, encoding: .utf8)
    //                print(printableData)
                    let hostRep = try decoder.decode(HostRepresentation.self, from: data)
                    guard let host = Host(hostRepresnetation: hostRep) else {
                        print("Error on line: \(#line) in function: \(#function)\n")
                        completion(.failure(.noDataError))
                        return
                    }
                    completion(.success(host))
                } catch {
                    print("""
                        Error on line: \(#line) in function: \(#function)\n
                        Readable error: \(error.localizedDescription)\n Technical error: \(error)
                        """)
                    completion(.failure(.unknownError(error)))
                }
            }
        }


    // MARK: - Fetch All Hosts

    /**
     This method makes a network call to fetch all Host objects on the server and completes with an array of Host objects or HostErrors Enum
    
     - Parameter completion: Completes with an array of Host objects or HostErrors Enum.
     */

    func fetchAllHostsFromServer(completion: @escaping (Result<[Host], HostErrors>) -> Void) {
        let url = baseURL.appendingPathComponent("djs")
        let urlRequest = URLRequest(url: url)

        dataLoader.loadData(from: urlRequest) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("HTTPResponse: \(response.statusCode) in function: \(#function)")
            }

            if let error = error {
                print("""
                    Error: \(error.localizedDescription) on line \(#line)
                    in function: \(#function)\n Technical error: \(error)
                    """)
                completion(.failure(.unknownError(error)))
            }

            guard let data = data else {
                print("Error on line: \(#line) in function: \(#function)")
                completion(.failure(.noDataError))
                return
            }

            let decoder = JSONDecoder()

            do {
//                let printableData = String(data: data, encoding: .utf8)
//                print(printableData)
                let hostRepArray = try decoder.decode([HostRepresentation].self, from: data)
                let hostArray: [Host] = hostRepArray.compactMap { Host(hostRepresnetation: $0) }
                completion(.success(hostArray))
            } catch {
                print("""
                    Error on line: \(#line) in function: \(#function)\n
                    Readable error: \(error.localizedDescription)\n Technical error: \(error)
                    """)
                completion(.failure(.unknownError(error)))
            }
        }
    }

    // MARK: - Register New Host
    /**
     This method makes a network call to register or save a Host object to the server and completes with a HostRegistrationResponse object or HostErrors Enum
    
     - Parameter Host: Host to save on the server
     - Parameter completion: Completes with HostRegistrationResponse object or HostErrors Enum.
     */

    func registerHost(with host: Host, completion: @escaping (Result<HostRegistrationResponse, HostErrors>) -> Void) {
        //take the host and turn in into a hr
        guard let hostRegistration =  host.hostRegistration else { return }
        //create url
        let registrationURL = baseURL.appendingPathComponent("register").appendingPathComponent("dj")

        //create url request method
        var urlRequest = URLRequest(url: registrationURL)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        //pass data into httpBody
        do {
            urlRequest.httpBody = try JSONEncoder().encode(hostRegistration)
        } catch {
            print("Error in function: \(#function)\n error: \(error.localizedDescription)\n Technical error: \(error)")
        }

        //urlsession.shared.dataTask
        dataLoader.loadData(from: urlRequest) { (data, response, error) in

            // NOTE: an error of 409 means that the username already exists
            if let response = response as? HTTPURLResponse {
                print("HTTPResponse: \(response.statusCode) in function: \(#function)")
            }

            if let error = error {
                print("Error: \(error.localizedDescription) in function: \(#function)\n Technical error: \(error)")
                completion(.failure(.registrationError(error)))
            }

            guard let data = data else {
                print("Error on line: \(#line) in function: \(#function)")
                completion(.failure(.noDataError))
                return
            }

            do {
                let hostRegistrationResponse = try JSONDecoder().decode(HostRegistrationResponse.self, from: data)
                completion(.success(hostRegistrationResponse))
            } catch {
                print("Error in func: \(#function)\n error: \(error.localizedDescription)\n Technical error: \(error)")
                completion(.failure(.unknownError(error)))
            }
        }
    }

    // MARK: - Log In Existing Host

    /**
     This method takes the information from the HostLogin object and makes a network call to allow a Host to login and completes with a HostLoginResponse object or HostErrors Enum
     - Note: the server returns the host properties along with the generated bearer token
     - Parameter host: HostLogin object to be encoded in the body of the urlRequest.
     - Parameter completion: Completes with HostLoginResponse object or HostErrors Enum.
     */

    func logIn(with host: HostLogin, completion: @escaping (Result<HostLoginResponse, HostErrors>) -> Void) {
        //take the host and turn in into a host login
        let hostLogin = host

        //create url
        let registrationURL = baseURL.appendingPathComponent("login").appendingPathComponent("dj")

        var urlRequest = URLRequest(url: registrationURL)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            urlRequest.httpBody = try JSONEncoder().encode(hostLogin)
        } catch {
            print("Error encoding HostLogin:\n error: \(error.localizedDescription)\n Technical error: \(error)")
        }

        //urlsession.shared.dataTask
        dataLoader.loadData(from: urlRequest) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("HTTPResponse: \(response.statusCode) in function: \(#function)")
            }

            if let error = error {
                print("Error: \(error.localizedDescription) in func: \(#function)\n Technical error: \(error)")
                completion(.failure(.loginError(error)))
            }

            guard let data = data else {
                print("Error on line: \(#line) in function: \(#function)")
                completion(.failure(.noDataError))
                return
            }

            do {
                let hostLoginResponse = try JSONDecoder().decode(HostLoginResponse.self, from: data)
                Bearer.shared.token = try JSONDecoder().decode(Bearer.self, from: data).token

                completion(.success(hostLoginResponse))
            } catch {
                print("Error in func: \(#function)\n error: \(error.localizedDescription)\n Technical error: \(error)")
                completion(.failure(.unknownError(error)))
            }
        }
    }

    // MARK: - Update Existing Host

    /**
     This method makes a network call to update a Host object on the server and saves it to core data if it completes with a Host object.
    
     - Parameter host: Host to be updated on the server and saved to core data accordingly.
     - Parameter completion: Completes with HostUpdate object or HostErrors Enum.
     */

    func updateHost(with host: Host, completion: @escaping (Result<HostUpdate, HostErrors>) -> Void) {
        guard let hostRepresentation = host.hostUpdate else { return }
        guard let bearer = Bearer.shared.token else {
            completion(.failure(.noAuthorization))
            return
        }

        let requestURL = baseURL.appendingPathComponent("auth")
            .appendingPathComponent("dj")
            .appendingPathComponent("\(host.identifier)")

        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = HTTPMethod.put.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("\(bearer)", forHTTPHeaderField: "Authorization")

        do {
            let encoder = JSONEncoder()
//            encoder.keyEncodingStrategy = .convertToSnakeCase
            urlRequest.httpBody = try encoder.encode(hostRepresentation)
        } catch {
            print("Error encoding HostUpdate:\n error: \(error.localizedDescription)\n Technical error: \(error)")
        }

        dataLoader.loadData(from: urlRequest) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("HTTPResponse: \(response.statusCode) in function: \(#function)")
            }

            if let error = error {
                print("Error: \(error.localizedDescription) in func: \(#function)\n Technical error: \(error)")
                completion(.failure(.loginError(error)))
            }

            guard let data = data else {
                print("Error on line: \(#line) in function: \(#function)")
                completion(.failure(.noDataError))
                return
            }

            do {
                let updateHostResponse = try JSONDecoder().decode(HostUpdate.self, from: data)
                try CoreDataStack.shared.save()
                completion(.success(updateHostResponse))
            } catch {
                print("Error in func: \(#function)\n error: \(error.localizedDescription)\n Technical error: \(error)")
                completion(.failure(.unknownError(error)))
            }
        }
    }

    // MARK: - Delete Host
}
