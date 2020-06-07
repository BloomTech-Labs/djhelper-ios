//
//  EventController.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/1/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation
import CoreData

class EventController {
    enum EventErrors: Error {
        case authorizationError(Error)
        case noDataError
        case encodeError(Error)
        case decodeError(Error)
        case otherError(Error)
        case noEventsInServerOrCoreData
    }

    private let baseURL = URL(string: "https://dj-helper-be.herokuapp.com/api")!
    let dataLoader: NetworkDataLoader

    init(dataLoader: NetworkDataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    // MARK: - FETCH ALL EVENTS
    func fetchAllEventsFromServer(for host: Host, completion: @escaping(Result<[Event], EventErrors>) -> Void) {
        let url = baseURL.appendingPathComponent("events")
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
                completion(.failure(.otherError(error)))
            }

            guard let data = data else {
                print("Error on line: \(#line) in function: \(#function)")
                completion(.failure(.noDataError))
                return
            }

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            do {
                let eventRepArray = try decoder.decode([EventRepresentation].self, from: data)
                print("eventRepArray's count: \(eventRepArray.count)")

                if let cdAndServerEvents = self.compareServerEvents(host: host, eventRepArray) {
                    completion(.success(cdAndServerEvents))
                } else {
                     print("Error- no cd or server events on line: \(#line) in function: \(#function)\n")
                    completion(.failure(.noEventsInServerOrCoreData))
                }

            } catch {
                 print("""
                    Error on line: \(#line) in function: \(#function)\n
                    Readable error: \(error.localizedDescription)\n Technical error: \(error)
                    """)
                completion(.failure(.decodeError(error)))
            }
        }
    }

    func compareServerEvents(host: Host, _ eventRepresentationArray: [EventRepresentation]) -> [Event]? {
        // TODO: - FIX LATER
        let eventsWithCurrentHostIDs = eventRepresentationArray.filter { $0.hostID == host.identifier }

        //check core data
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()

         // TODO: - FIX LATER
        let predicate = NSPredicate(format: "hostID == %i", host.identifier)
        fetchRequest.predicate = predicate

        var placeHolderArray: [Event] = []

        do {
            let eventsInCoreData = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
            print("events in coreDataArray's count: \(eventsInCoreData.count)")

            //loop
            for event in eventsInCoreData {
            placeHolderArray = eventsWithCurrentHostIDs.filter {
                $0.name != event.name }.compactMap {
                Event(eventRepresentation: $0)
                }
            }

            return placeHolderArray

        } catch {
            print("""
                Error on line: \(#line) in function: \(#function)\n
                Readable error: \(error.localizedDescription)\n Technical error: \(error)
                """)
            return []
        }
    }

    // MARK: - AUTHORIZE AN EVENT
    ///The server returns an object with the event data
    func authorize(event: Event, completion: @escaping (Result<EventRepresentation, EventErrors>) -> Void) {
        guard let eventToAuthorize = event.eventAuthorizationRep else { return }
//        guard let eventAuthRequest = event.eventAuthRequest else { return }

        let url = baseURL.appendingPathComponent("auth").appendingPathComponent("event")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
//        encoder.keyEncodingStrategy = .convertToSnakeCase

        do {
            try CoreDataStack.shared.save()
            urlRequest.httpBody = try encoder.encode(eventToAuthorize)
        } catch {
            print("Error in func: \(#function)\n error: \(error.localizedDescription)\n Technical error: \(error)")
            completion(.failure(.encodeError(error)))
            return
        }
        print("this is the url: \(baseURL.absoluteString)")

        dataLoader.loadData(from: urlRequest) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("HTTPResponse: \(response.statusCode) in function: \(#function)")
            }

            if let error = error {
               print("Error in func: \(#function)\n error: \(error.localizedDescription)\n Technical error: \(error)")
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
                print("Error in func: \(#function)\n error: \(error.localizedDescription)\n Technical error: \(error)")
                completion(.failure(.decodeError(error)))
            }
        }
    }
}
