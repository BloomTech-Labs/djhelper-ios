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
        case errorUpdatingEventOnServer(Error)
        case otherError(Error)
        case noEventsInServerOrCoreData
        case couldNotInitializeAnEvent
    }

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
                     type: String,
                     notes: String) -> Event {
            event.name = eventName
            event.eventDate = eventDate
            event.eventDescription = description
            event.eventType = type
            event.notes = notes

        return event
    }

    func saveUpdateEvent(_ event: Event,
                         completion: @escaping (Result<(), EventErrors>) -> Void) {
        guard let eventRep = event.eventAuthorizationRep, let eventId = eventRep.eventID else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return
        }

        let authURL = baseURL.appendingPathComponent("auth")
        let eventURL = authURL.appendingPathComponent("event")
        let finalURL = eventURL.appendingPathComponent("\(eventId)")
        print("finalURL: \(finalURL.absoluteURL)")

        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = HTTPMethod.put.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

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
        event.eventType = eventRep.eventType
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
        guard let eventToAuthorize = event.eventAuthRequest else { return }

        let url = baseURL.appendingPathComponent("auth").appendingPathComponent("event")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        do {
            try CoreDataStack.shared.save()
            urlRequest.httpBody = try encoder.encode(eventToAuthorize)
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

    // TODO: add delete event method

    // TODO: add update event method
}
