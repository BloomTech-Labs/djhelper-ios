//
//  EventController.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/1/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation
import CoreData

enum EventErrors: Error {
    case authorizationError(Error)
    case noDataError
    case encodeError(Error)
    case decodeError(Error)
    case errorUpdatingEventOnServer(Error)
    case otherError(Error)
    case noEventsInServerOrCoreData
    case couldNotInitializeAnEvent
}

class EventController {
    private let baseURL = URL(string: "https://dj-helper-be.herokuapp.com/api")!
    let dataLoader: NetworkDataLoader

    init(dataLoader: NetworkDataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    // MARK: - UPDATE EVENT
    func updateEvent(event: Event,
                     eventName: String,
                     eventDate: Date,
                     description: String,
                     explicit: Bool) -> Event {
            event.name = eventName
            event.eventDate = eventDate
            event.eventDescription = description
            event.isExplicit = explicit

        return event
    }

    func saveUpdateEvent(_ event: Event,
                         completion: @escaping (Result<(), EventErrors>) -> Void) {
        guard let eventRep = event.eventAuthorizationRep, let eventId = eventRep.eventID else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return
        }
        guard let bearer = Bearer.shared.token else {
            completion(.failure(.couldNotInitializeAnEvent))
            return
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             }

        let authURL = baseURL.appendingPathComponent("auth")
        let eventURL = authURL.appendingPathComponent("event")
        let finalURL = eventURL.appendingPathComponent("\(eventId)")

        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = HTTPMethod.put.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("\(bearer)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted

        do {
            urlRequest.httpBody =  try encoder.encode(eventRep)
            let httpbody = try encoder.encode(eventRep)
            print("httpbody: \(String(describing: String(data: httpbody, encoding: .utf8)))")
        } catch {
            print("""
                Error on line: \(#line) in function: \(#function)\n
                Readable error: \(error.localizedDescription)\n Technical error: \(error)
                """)
        }

        dataLoader.loadData(from: urlRequest) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("HTTPResponse: \(response.statusCode) in function: \(#function)")
            }

            if let error = error {
                print("""
                    Error: \(error.localizedDescription) on line \(#line)
                    in function: \(#function)\n Technical error: \(error)
                    """)
                DispatchQueue.main.async {
                    completion(.failure(.noEventsInServerOrCoreData))
                }
            }

            guard let data = data else {
                print("Error on line: \(#line) in function: \(#function)\n")
                DispatchQueue.main.async {
                    completion(.failure(.noDataError))
                }
                return
            }

            print("data for decoding EVENT REP: \(String(describing: String(data: data, encoding: .utf8)))")

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            do {
                let eventRep = try decoder.decode(EventRepresentation.self, from: data)
                    self.update(event: event, withEventRep: eventRep)
                DispatchQueue.main.async {
                    completion(.success(()))
                }
            } catch {
                print("""
                    Error on line: \(#line) in function: \(#function)\n
                    Readable error: \(error.localizedDescription)\n Technical error: \(error)
                    """)
                DispatchQueue.main.async {
                    completion(.failure(.decodeError(error)))
                }
            }
        }
    }

    func update(event: Event, withEventRep eventRep: EventRepresentation) {
        event.name = eventRep.name
        event.isExplicit = eventRep.isExplicit
        event.eventDescription = eventRep.eventDescription
        event.eventDate = eventRep.eventDate.dateFromString()
        event.hostID = eventRep.hostID
        if let eventID =  eventRep.eventID {
            event.eventID = eventID
        } else {
            print("Error NO EVENTID FROM EVENTREP on line: \(#line) in function: \(#function)\n")
        }

        do {
            try CoreDataStack.shared.save()
        } catch {
            print("""
                Error on line: \(#line) in function: \(#function)\n
                Readable error: \(error.localizedDescription)\n Technical error: \(error)
                """)
        }
    }

    // MARK: - FETCH ALL EVENTS
    func fetchAllEventsFromServer(completion: @escaping(Result<[Event], EventErrors>) -> Void) {
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
                let eventArray: [Event] = eventRepArray.compactMap { Event(eventRepresentation: $0 )}
                completion(.success(eventArray))
            } catch {
                print("""
                    Error on line: \(#line) in function: \(#function)\n
                    Readable error: \(error.localizedDescription)\n Technical error: \(error)
                    """)
                completion(.failure(.decodeError(error)))
            }
        }
    }

    // MARK: - Fetch Specific Event from server
    func fetchEvent(withEventID id: Int, completion: @escaping(Result<Bool, EventErrors>) -> Void) {
        let url = baseURL.appendingPathComponent("event")
        let finalURL = url.appendingPathComponent("\(id)")
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
                let eventRep = try decoder.decode(EventRepresentation.self, from: data)
                print("event: \(eventRep.name)\n, ID\(eventRep.eventID)\n hostID: \(eventRep.hostID)")
                completion(.success(true))

            } catch {
                 print("""
                    Error on line: \(#line) in function: \(#function)\n
                    Readable error: \(error.localizedDescription)\n Technical error: \(error)
                    """)
                completion(.failure(.decodeError(error)))
            }
        }
    }

    // MARK: - FETCH EVENTS FOR HOST
    func fetchAllEventsFromServer(for host: Host, completion: @escaping(Result<Bool, EventErrors>) -> Void) {
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

                // When the array of representations is made from the JSON, the update method is called
                // This filters the events by using our host identifier
                // and then compares that array of events with events in core data
                // If an event in core data was not on the server, it is deleted
                // If an event in core data was also on the server, we call a method to update desired properties
                // If an event on the server, was not in core data, it is created and saved to core data
                try self.updateEventsFromServer(events: eventRepArray, withHost: host)
                completion(.success(true))

            } catch {
                 print("""
                    Error on line: \(#line) in function: \(#function)\n
                    Readable error: \(error.localizedDescription)\n Technical error: \(error)
                    """)
                completion(.failure(.decodeError(error)))
            }
        }
    }

    func updateEventsFromServer(events eventRespresentations: [EventRepresentation], withHost host: Host) throws {
        let eventsWithHost = eventRespresentations.filter { $0.hostID == host.identifier }
        let eventIdentifiers = eventsWithHost.compactMap { $0.eventID }

        let representationsByID = Dictionary(uniqueKeysWithValues: zip(eventIdentifiers, eventsWithHost))
        var eventsToCreate = representationsByID

        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        let moc = CoreDataStack.shared.container.newBackgroundContext()

        moc.perform {
            do {
                let existingEvents = try moc.fetch(fetchRequest)

                for event in existingEvents {
                    let eventID = event.eventID
                    guard let representation = representationsByID[eventID] else {
                        moc.delete(event)
                        continue
                    }

                    self.updateCoreDataEvent(event: event, representation: representation)

                    eventsToCreate.removeValue(forKey: eventID)
                }

                // whatever is left from the server, make into an Event
                for representation in eventsToCreate.values {
                    Event(eventRepresentation: representation, context: moc)
                }
            } catch {
                print("Error fetching events for identifiers: \(error)")
            }
        }
        try CoreDataStack.shared.save(context: moc)
    }

    func updateCoreDataEvent(event: Event, representation: EventRepresentation) {
        event.name = representation.name
        event.eventDescription = representation.eventDescription
        event.isExplicit = representation.isExplicit
        event.eventDate = representation.eventDate.dateFromString()
        event.imageURL = representation.imageURL
    }

    // MARK: - AUTHORIZE AN EVENT
    ///The server returns an object with the event data
    func authorize(event: Event, completion: @escaping (Result<EventRepresentation, EventErrors>) -> Void) {
        guard let eventToAuthorize = event.eventAuthRequest else { return }
        guard let bearer = Bearer.shared.token else {
            completion(.failure(.couldNotInitializeAnEvent))
            return
        }

        let url = baseURL.appendingPathComponent("auth")
            .appendingPathComponent("event")

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("\(bearer)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            urlRequest.httpBody = try encoder.encode(eventToAuthorize)
            print(String(data: urlRequest.httpBody!, encoding: .utf8))
        } catch {
            print("Error in func: \(#function)\n error: \(error.localizedDescription)\n Technical error: \(error)")
            completion(.failure(.encodeError(error)))
            return
        }

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
//                print("date from eventRep: \(eventRep.eventDate)")
                self.updateEventID(for: event, with: eventRep)
                completion(.success(eventRep))
            } catch {
                print("Error in func: \(#function)\n error: \(error.localizedDescription)\n Technical error: \(error)")
                completion(.failure(.decodeError(error)))
            }
        }
    }

    func updateEventID(for event: Event, with eventRep: EventRepresentation) {
        guard let eventID = eventRep.eventID else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return
        }
        event.eventID = eventID
        do {
            try CoreDataStack.shared.save()
        } catch {
            print("""
                Error on line: \(#line) in function: \(#function)\n
                Readable error: \(error.localizedDescription)\n Technical error: \(error)
                """)
        }
    }
}
