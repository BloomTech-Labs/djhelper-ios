//
//  EventController.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/1/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation
class EventController {
    enum EventErrors: Error {
        case authorizationError(Error)
        case noDataError
        case encodeError(Error)
        case decodeError(Error)
        case otherError(Error)
    }
    private let baseURL = URL(string: "https://api.dj-helper.com/api/auth/event/")!
    let dataLoader: NetworkDataLoader
    
    init(dataLoader: NetworkDataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }
    
    // MARK: - AUTHORIZE AN EVENT
    ///The server returns an object with the event data
    func authorize(event: Event, completion: @escaping (Result<EventRepresentation, EventErrors>) -> Void) {
        guard let eventToAuthorize = event.eventAuthorizationRep else { return }
//        guard let eventAuthRequest = event.eventAuthRequest else { return }
        
        var urlRequest = URLRequest(url: baseURL)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
//        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        do {
            urlRequest.httpBody = try encoder.encode(eventToAuthorize)
        } catch {
            print("Error on line: \(#line) in function: \(#function)\n Readable error: \(error.localizedDescription)\n Technical error: \(error)")
            completion(.failure(.encodeError(error)))
            return
        }
        print("this is the url: \(baseURL.absoluteString)")

        dataLoader.loadData(from: urlRequest) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("HTTPResponse: \(response.statusCode) in function: \(#function)")
            }

            if let error = error {
                print("Error: \(error.localizedDescription) on line \(#line) in function: \(#function)\n Technical error: \(error)")
                completion(.failure(.otherError(error)))
                return
            }
        
            guard let data = data else {
                print("Error on line: \(#line) in function: \(#function)")
                completion(.failure(.noDataError))
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            do {
                let eventRep = try decoder.decode(EventRepresentation.self, from: data)
                print("date from eventRep: \(eventRep.eventDate)")
                completion(.success(eventRep))
            } catch {
                 print("Error on line: \(#line) in function: \(#function)\n Readable error: \(error.localizedDescription)\n Technical error: \(error)")
                completion(.failure(.decodeError(error)))
            }
        }
    }
}
