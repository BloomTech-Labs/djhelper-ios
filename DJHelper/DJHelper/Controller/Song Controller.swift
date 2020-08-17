//
//  Song Controller.swift
//  DJHelper
//
//  Created by Craig Swanson on 7/15/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum SongError: Error {
    case authorizationError(Error)
    case noDataError
    case encodeError(Error)
    case decodeError(Error)
    case errorUpdatingEventOnServer(Error)
    case otherError(Error)
    case noEventsInServerOrCoreData
    case couldNotInitializeAnEvent
}

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
    func fetchAllSongsFromServer(completion: @escaping(Result<[TrackRepresentation], EventErrors>) -> Void) {
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
                let songRepresentationArray = try decoder.decode([TrackRepresentation].self,
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

    func fetchSetlistFromServer(for event: Event, completion: @escaping(Result<[Song], EventErrors>) -> Void) {
        let eventURL = baseURL.appendingPathComponent("event")
        let eventIdURL = eventURL.appendingPathComponent("\(event.eventID)")
        let playlistURL = eventIdURL.appendingPathComponent("playlist")
        let urlRequest = URLRequest(url: playlistURL)

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
                let trackResponses = try decoder.decode([TrackResponse].self, from: data)
                var songs = [Song]()
                for track in trackResponses {
                    let newSong = Song(artist: track.artist, externalURL: track.externalURL, songId: track.spotifyId, songName: track.songName, preview: track.preview, image: track.image, songID: track.trackId)
                    songs.append(newSong)
                }
                print("print songs in setlist: \(songs.count) on line: \(#line)")
                completion(.success(songs))
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
    
    // MARK: - Fetch Setlist for Event -- json we get back looks like TrackResponse vs Representation
//    func fetchSetlistFromServer(for event: Event, completion: @escaping(Result<[TrackRepresentation], EventErrors>) -> Void) {
//        let eventURL = baseURL.appendingPathComponent("event")
//        let eventIdURL = eventURL.appendingPathComponent("\(event.eventID)")
//        let playlistURL = eventIdURL.appendingPathComponent("playlist")
//        let urlRequest = URLRequest(url: playlistURL)
//
//        dataLoader.loadData(from: urlRequest) { possibleData, possibleResponse, possibleError in
//            if let response = possibleResponse as? HTTPURLResponse {
//                print("HTTPResponse: \(response.statusCode) in function: \(#function)")
//            }
//
//            if let error = possibleError {
//                print("""
//                    Error: \(error.localizedDescription) on line \(#line)
//                    in function: \(#function)\nTechnical error: \(error)
//                    """)
//                completion(.failure(.otherError(error)))
//                return
//            }
//
//            guard let data = possibleData else {
//                print("Error on line: \(#line) in function: \(#function)")
//                completion(.failure(.noDataError))
//                return
//            }
//
//            let decoder = JSONDecoder()
//            do {
//                let songRepresentationArray = try decoder.decode([TrackRepresentation].self,
//                                                                 from: data)
//                completion(.success(songRepresentationArray))
//            } catch {
//                print("""
//                    Error on line: \(#line) in function \(#function)
//                    Readable error: \(error.localizedDescription)\nTechnical error:
//                    \(error)
//                    """)
//                completion(.failure(.decodeError(error)))
//            }
//        }
//    }

    // MARK: - Search for Song - doesn't return trackId
    func searchForSong(withSearchTerm search: String, completion: @escaping(Result<[TrackRepresentation], SongError>) -> Void) {
        let url = baseURL.appendingPathComponent("track").appendingPathComponent("\(search)")
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
                let songRepresentationArray = Array(try decoder.decode([String: TrackRepresentation].self,
                    from: data).values)
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

    // MARK: - Add Song to Playlist
    func addSongToPlaylist(song: Song, completion: @escaping (Result<(), SongError>) -> Void) {

        guard let bearer = Bearer.shared.token else {
            print("Error on line: \(#line) in function: \(#function)\n")
            //CHANGE ERROR
            completion(.failure(.noEventsInServerOrCoreData))
            return
            }

        guard let trackResponse = song.songToTrackResponse else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return
        }
        print("TrackResponse to add song to setlist: \(trackResponse)")
        let authURL = baseURL.appendingPathComponent("auth")
        let trackURL = authURL.appendingPathComponent("track")
        let moveURL = trackURL.appendingPathComponent("move")
        let trackIdURL = moveURL.appendingPathComponent("\(song.songID)")

        var urlRequest = URLRequest(url: trackIdURL)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("\(bearer)", forHTTPHeaderField: "Authorization")

        let encoder = JSONEncoder()
        do {
            urlRequest.httpBody = try encoder.encode(trackResponse)
        } catch {
            print("Error on line: \(#line) in function: \(#function)\nReadable error: \(error.localizedDescription)\n Technical error: \(error)")
        }

        dataLoader.loadData(from: urlRequest) { (_, response, error) in
            if let response = response as? HTTPURLResponse {
                print("HTTPResponse: \(response.statusCode) in function: \(#function)")
            }

            if let error = error {
                print("Error: \(error.localizedDescription) on line \(#line) in function: \(#function)\n Technical error: \(error)")
                completion(.failure(.otherError(error)))
            }

//            guard let data = data else {
//                print("Error on line: \(#line) in function: \(#function)")
//                completion(.failure(.noDataError))
//                return
//            }
//            print(" Data we get back from posting song to setlist\(String(data: data, encoding: .utf8))")
            completion(.success(()))
        }
    }
    // MARK: - Delete Song from Playlist
    func deleteSongFromPlaylist(track: TrackResponse, completion: @escaping (Result<(), SongError>) -> Void) {
         guard let bearer = Bearer.shared.token else {
             print("Error on line: \(#line) in function: \(#function)\n")
             //CHANGE ERROR
             completion(.failure(.noEventsInServerOrCoreData))
             return
             }

         let authURL = baseURL.appendingPathComponent("auth")
         let trackURL = authURL.appendingPathComponent("track")
        let playlistURL = trackURL.appendingPathComponent("playlist")
         let trackIdURL = playlistURL.appendingPathComponent("\(track.trackId)")

         var urlRequest = URLRequest(url: trackIdURL)
         urlRequest.httpMethod = HTTPMethod.delete.rawValue
         urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
         urlRequest.setValue("\(bearer)", forHTTPHeaderField: "Authorization")

         let encoder = JSONEncoder()
         do {
             urlRequest.httpBody = try encoder.encode(track)
         } catch {
             print("Error on line: \(#line) in function: \(#function)\nReadable error: \(error.localizedDescription)\n Technical error: \(error)")
         }

         dataLoader.loadData(from: urlRequest) { (data, response, error) in
             if let response = response as? HTTPURLResponse {
                 print("HTTPResponse: \(response.statusCode) in function: \(#function)")
             }

             if let error = error {
                 print("Error: \(error.localizedDescription) on line \(#line) in function: \(#function)\n Technical error: \(error)")
                 completion(.failure(.otherError(error)))
             }

             guard let _ = data else {
                 print("Error on line: \(#line) in function: \(#function)")
                 completion(.failure(.noDataError))
                 return
             }
             completion(.success(()))
         }
     }

    // MARK: - Add Song to Requests
    // TODO: - Maybe we should return a TrackResponse based on the json we get back
    func addSongToRequest(_ song: TrackRequest, completion: @escaping (Result<TrackResponse, SongError>) -> Void) {
//        guard let trackRepresntation = song.songRepresentation else {
//            print("Error on line: \(#line) in function: \(#function)\n")
//            return
//        }

    //put trackRepresntation in body of http
        let url = baseURL.appendingPathComponent("track")
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = HTTPMethod.post.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let encoder = JSONEncoder()

        do {
            urlRequest.httpBody = try encoder.encode(song)
        } catch {
            print("Readable error: \(error.localizedDescription)\n Technical error: \(error)")
            completion(.failure(.encodeError(error)))
            return
        }

        dataLoader.loadData(from: urlRequest) { (data, response, error) in
            if let response = response as? HTTPURLResponse {
                print("HTTPResponse: \(response.statusCode) in function: \(#function)")
            }

            if let error = error {
                print("Readable error: \(error.localizedDescription)\n Technical error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.otherError(error)))
                }
                return
            }

            guard let data = data else {
                print("Error on line: \(#line) in function: \(#function)")
                DispatchQueue.main.async {
                    completion(.failure(.noDataError))
                }
                return
            }

            let decoder = JSONDecoder()

            do {
                let track = try decoder.decode(TrackResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(track))
                }
                print("data returned from addingSongToRequest: \(String(describing: String(data: data, encoding: .utf8)))")
            } catch {
                print("Readable error: \(error.localizedDescription)\n Technical error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.decodeError(error)))
                }
            }
        }
    }

    // MARK: - Fetch ALL Songs/Tracks from server
    /// This completes with Song
    func fetchAllTracksFromRequestList(forEventId: Int, completion: @escaping (Result<[Song], SongError>) -> Void) {
        let eventURL = baseURL.appendingPathComponent("event")
        let eventIdURL = eventURL.appendingPathComponent("\(forEventId)")
        let finalURL = eventIdURL.appendingPathComponent("tracks")
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
                DispatchQueue.main.async {
                    completion(.failure(.otherError(error)))
                }
                return
            }

            guard let data = data else {
                print("Error on line: \(#line) in function: \(#function)")
                DispatchQueue.main.async {
                    completion(.failure(.noDataError))
                }
                return
            }

            let decoder = JSONDecoder()

            do {
                //turn the array of taskreps into songs
                let trackResponses = try decoder.decode([TrackResponse].self, from: data)
                var songArray: [Song] = []
                for track in trackResponses {
                    let newSong = Song(artist: track.artist,
                                       externalURL: track.externalURL,
                                       songId: track.spotifyId,
                                       songName: track.songName,
                                       preview: track.preview,
                                       image: track.image,
                                       songID: track.trackId)
                    songArray.append(newSong)
                }
                completion(.success(songArray))
            } catch {
                print("Readable error: \(error.localizedDescription)\n Technical error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(.decodeError(error)))
                }
                return
            }
        }
    }

    // MARK: - Delete Song from Requests
    func deleteTrackFromRequests(trackId: Int, completion: @escaping (Result<Bool, SongError>) -> Void) {

        guard let bearer = Bearer.shared.token else {
            print("Error on line: \(#line) in function: \(#function)\n")
            //CHANGE ERROR
            completion(.failure(.noEventsInServerOrCoreData))
            return
        }

        let authURL = baseURL.appendingPathComponent("auth")
        let trackURL = authURL.appendingPathComponent("track")
        let trackIdURL = trackURL.appendingPathComponent("\(trackId)")
        var urlRequest = URLRequest(url: trackIdURL)

        urlRequest.httpMethod = HTTPMethod.delete.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("\(bearer)", forHTTPHeaderField: "Authorization")
        //nothing goes into the body
        dataLoader.loadData(from: urlRequest) { (_, response, error) in
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
         // nothing comes back
            completion(.success(true))
        }
    }

    // MARK: - Upvote Song
}

extension SongController {
    func fetchCoverArt(url: URL, completion: @escaping (Result<UIImage, SongError>) -> Void) {
        let urlRequest = URLRequest(url: url)

        dataLoader.loadData(from: urlRequest) { (possibleData, possibleResponse, possibleError) in
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

            if let image = UIImage(data: data) {
                completion(.success(image))
            } else {
                print("Could not retrieve cover art image")
                completion(.failure(.noDataError))
            }
        }
    }
}
