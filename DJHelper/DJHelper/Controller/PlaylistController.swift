//
//  PlaylistController.swift
//  DJHelper
//
//  Created by Michael Flowers on 8/10/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

enum PlaylistError: Error {
     case authorizationError(Error)
       case noDataError
       case encodeError(Error)
       case decodeError(Error)
       case noPlaylistOnServer(Error)
       case otherError(Error)
        case noToken
}

class PlaylistController {
    private let baseURL = URL(string: "https://dj-helper-be.herokuapp.com/api")!

    let dataLoader: NetworkDataLoader

    init(dataLoader: NetworkDataLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    func post(playlist: Playlist, completion: @escaping (Result<Bool, PlaylistError>) -> Void) {

        guard let bearer = Bearer.shared.token else {
            print("Error on line: \(#line) in function: \(#function)\n")
            completion(.failure(.noToken))
            return
        }
        
        let authURL = baseURL.appendingPathComponent("auth")
        let playlistURL = authURL.appendingPathComponent("playlist")
        let finalURL = playlistURL.appendingPathComponent("\(playlist.eventID)")

        var urlRequest = URLRequest(url: finalURL)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("\(bearer)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            urlRequest.httpBody = try encoder.encode(playlist)
            let httpBody = try encoder.encode(playlist)
            print("httpbody: \(String(describing: String(data: httpBody, encoding: .utf8)))")
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
                    completion(.failure(.noPlaylistOnServer(error)))
                }
            }
            
            guard let data = data else {
                print("Error on line: \(#line) in function: \(#function)")
                DispatchQueue.main.async {
                    completion(.failure(.noDataError))
                }
                return
            }
            
             print("data for playlist: \(String(describing: String(data: data, encoding: .utf8)))")
            
            completion(.success(true))
        }
    }
} // End
