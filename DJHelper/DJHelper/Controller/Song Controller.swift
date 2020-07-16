//
//  Song Controller.swift
//  DJHelper
//
//  Created by Craig Swanson on 7/15/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation
import CoreData

class SongController {
    private let baseURL = URL(string: "https://dj-helper-be.herokuapp.com/api")!
    let dataLoader: NetworkDataLoader

    init(dataLoader: NetworkDataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    // NOTE: These methods will need to change based on the backend solution.
    // We will also very likely need to create additional representation models for songs
    // based on the inputs and outputs and the various server requests.

    // MARK: - Fetch All Songs
    func fetchAllSongsFromServer(completion: @escaping(Result<[SongRepresentation], EventErrors>) -> Void) {
        let url = baseURL.appendingPathComponent("songs")
        let urlRequest = URLRequest(url: url)

        dataLoader.loadData(from: urlRequest) { possibleData, possibleResponse, possibleError in
            if let response = possibleResponse as? HTTPURLResponse {
                print("HTTPResponse: \(response.statusCode) in function: \(#function)")
            }

            if let error = possibleError {
                print("""
                    Error: \(error.localizedDescription) on line \(#line)
                    in function: \(#function)\nTechnical error: \(error)
                    """)
                completion(.failure(.otherError(error)))
                return
            }

            guard let data = possibleData else {
                print("Error on line: \(#line) in function: \(#function)")
                completion(.failure(.noDataError))
                return
            }

            let decoder = JSONDecoder()
            do {
                let songRepresentationArray = try decoder.decode([SongRepresentation].self,
                                                                 from: data)
                completion(.success(songRepresentationArray))
            } catch {
                print("""
                    Error on line: \(#line) in function \(#function)
                    Readable error: \(error.localizedDescription)\nTechnical error:
                    \(error)
                    """)
                completion(.failure(.decodeError(error)))
            }
        }
    }

    // MARK: - Fetch Setlist for Event
    func fetchSetlistFromServer(for event: Event, completion: @escaping(Result<[SongRepresentation], EventErrors>) -> Void) {
        let url = baseURL.appendingPathComponent("playlist").appendingPathComponent("\(event.eventID)")
        let urlRequest = URLRequest(url: url)

        dataLoader.loadData(from: urlRequest) { possibleData, possibleResponse, possibleError in
            if let response = possibleResponse as? HTTPURLResponse {
                print("HTTPResponse: \(response.statusCode) in function: \(#function)")
            }

            if let error = possibleError {
                print("""
                    Error: \(error.localizedDescription) on line \(#line)
                    in function: \(#function)\nTechnical error: \(error)
                    """)
                completion(.failure(.otherError(error)))
                return
            }

            guard let data = possibleData else {
                print("Error on line: \(#line) in function: \(#function)")
                completion(.failure(.noDataError))
                return
            }

            let decoder = JSONDecoder()
            do {
                let songRepresentationArray = try decoder.decode([SongRepresentation].self,
                                                                 from: data)
                completion(.success(songRepresentationArray))
            } catch {
                print("""
                    Error on line: \(#line) in function \(#function)
                    Readable error: \(error.localizedDescription)\nTechnical error:
                    \(error)
                    """)
                completion(.failure(.decodeError(error)))
            }
        }
    }

    // MARK: - Search for Song

    // MARK: - Add Song to Playlist

    // MARK: - Delete Song from Playlist

    // MARK: - Add Song to Requests

    // MARK: - Delete Song from Requests

    // MARK: - Upvote Song
}
