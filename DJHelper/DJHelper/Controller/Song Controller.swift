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

/// SongError Enum to better handle error that may arise from network calls
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

    // MARK: - Fetch All Songs

    /**
     This method makes a network call to fetch all Song object from the server and completes with an array of TrackRepresentation objects or SongError Enum.

     - Parameter completion: Completes with an array of TrackRepresentation objects or SongError Enum.
     */

    func fetchAllSongsFromServer(completion: @escaping(Result<[TrackRepresentation], SongError>) -> Void) {
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

    /**
     This method makes a network call to fetch a setlist for a specific Event object from the server and completes with an array of Song objects or SongError Enum.
    
     - Parameter event: To be used to get the ID to append the url to identify the specific Event on the server
     - Parameter completion: completes with an array of Song objects or SongError Enum.
     */

    func fetchSetlistFromServer(for event: Event, completion: @escaping(Result<[Song], SongError>) -> Void) {
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
                    let newSong = Song(artist: track.artist,
                                       externalURL: track.externalURL,
                                       songId: track.spotifyId,
                                       songName: track.songName,
                                       preview: track.preview,
                                       image: track.image,
                                       songID: track.trackId)
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

    /**
     This method makes a network call to add a specific Song object to a setlist and completes with void or SongError Enum.
    
     - Parameter song: To be used to get the SongID to append the url to for the network call
     - Parameter completion: completes with void or SongError Enum.
     */

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
            completion(.success(()))
        }
    }

    // MARK: - Delete Song from Playlist

    /**
     This method makes a network call to delete a song from a setlist on the server and completes with void or SongError Enum.
    
     - Parameter song: To be used to get the ID to append the url to identify the specific song to delete on the server
     - Parameter completion: completes with void or SongError Enum.
     */

    func deleteSongFromPlaylist(song: Song, completion: @escaping (Result<(), SongError>) -> Void) {
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

         let authURL = baseURL.appendingPathComponent("auth")
         let trackURL = authURL.appendingPathComponent("track")
         let playlistURL = trackURL.appendingPathComponent("playlist")
         let trackIdURL = playlistURL.appendingPathComponent("\(trackResponse.trackId)")
         var urlRequest = URLRequest(url: trackIdURL)
         urlRequest.httpMethod = HTTPMethod.delete.rawValue
         urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
         urlRequest.setValue("\(bearer)", forHTTPHeaderField: "Authorization")

         let encoder = JSONEncoder()
         do {
             urlRequest.httpBody = try encoder.encode(trackResponse)
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

    /**
     This method makes a network call to add a song to the request list on the server and completes with a TrackResponse object or SongError Enum.
    
     - Parameter song: TrackRequest object to be encoded in the httpBody to post to the server
     - Parameter completion: completes with a TrackResponse object or SongError Enum
     */
    func addSongToRequest(_ song: TrackRequest, completion: @escaping (Result<TrackResponse, SongError>) -> Void) {

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

    /**
     This method makes a network call to fetch all songs on the request list on the server for a specific event and completes with an array of Song objects or SongError Enum.
    
     - Parameter forEventId: EventID to append the url identifiying specific Event to fetch all songs on request list
     - Parameter completion: completes with an array of Song objects or SongError Enum
     */

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

    /**
     This method makes a network call to delete a specific song on the request list stored on the server and completes with void or SongError Enum.
    
     - Parameter trackId: trackId to append the url identifiying specific track to delete from request list on the server
     - Parameter completion: completes with void or SongError Enum
     */

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

    /**
     This method makes a network call to fetch URL for a song's cover art and completes with an UIImage or SongError Enum.
    
     - Parameter url: URL to use to create URLRequest for the network call. Returns data that we can use to initialize an UIImage
     - Parameter completion: completes with an UIImage or SongError Enum.
     */

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
