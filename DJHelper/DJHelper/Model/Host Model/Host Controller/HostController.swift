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
    // MARK: - HOST ERRORS
    enum HostErrors: Error {
        case registrationError(Error)
        case unknownError(Error)
        case loginError(Error)
        case noDataError
    }

    typealias HostHandler = (Result<Host, HostErrors>) -> Void

    private let baseURL = URL(string: "https://dj-helper-be.herokuapp.com/api")!
    var bearer: Bearer?

    let dataLoader: NetworkDataLoader

    init(dataLoader: NetworkDataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    // MARK: - Register New Host
    // the server returns the host properties along with the generated ID
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
    // the server returns the host properties along with the generated bearer token
    func logIn(with host: Host, completion: @escaping (Result<HostLoginResponse, HostErrors>) -> Void) {
        //take the host and turn in into a host login
        guard let hostLogin = host.hostLogin else { return }

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
                self.bearer = try JSONDecoder().decode(Bearer.self, from: data)

                completion(.success(hostLoginResponse))
            } catch {
                print("Error in func: \(#function)\n error: \(error.localizedDescription)\n Technical error: \(error)")
                completion(.failure(.unknownError(error)))
            }
        }
    }

    // MARK: - Update Existing Host
    func updateHost(with host: Host, completion: @escaping (Result<HostUpdate, HostErrors>) -> Void) {
        guard let hostRepresentation = host.hostUpdate else { return }

        let requestURL = baseURL.appendingPathComponent("auth")
            .appendingPathComponent("dj")
            .appendingPathComponent("\(host.identifier)")

        var urlRequest = URLRequest(url: requestURL)
        urlRequest.httpMethod = HTTPMethod.put.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let encoder = JSONEncoder()
            encoder.keyEncodingStrategy = .convertToSnakeCase
            urlRequest.httpBody = try encoder.encode(hostRepresentation)
            let jsonString = String(data: urlRequest.httpBody!, encoding: .utf8)
            print(jsonString)
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
                let printableDate = String(data: data, encoding: .utf8)
                print(printableDate)
                let updateHostResponse = try JSONDecoder().decode(HostUpdate.self, from: data)
                try CoreDataStack.shared.mainContext.save()
                completion(.success(updateHostResponse))
            } catch {
                print("Error in func: \(#function)\n error: \(error.localizedDescription)\n Technical error: \(error)")
                completion(.failure(.unknownError(error)))
            }
        }
    }

    // MARK: - Delete Host
    // server does not presently have a DEL for host(DJ)
}
