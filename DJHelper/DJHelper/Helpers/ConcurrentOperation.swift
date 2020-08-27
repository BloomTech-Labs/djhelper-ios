//
//  ConcurrentOperation.swift
//  DJHelper
//
//  Created by Craig Swanson on 8/17/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

// The ConcurrentOperation subclass was taken from an iOS project dealing with concurrency.
// It is a subclass of Operation that is generic in providing its own subclass the means to
// execute and stop functions in Operation Blocks.
class ConcurrentOperation: Operation {

    // MARK: Types
    enum State: String {
        case isReady, isExecuting, isFinished
    }

    // MARK: Properties
    private var _state = State.isReady
    private let stateQueue = DispatchQueue(label: "com.LambdaSchoolLabs.DJHelper.ConcurrentOperationStateQueue")
    var state: State {
        get {
            var result: State?
            let queue = self.stateQueue
            queue.sync {
                result = _state
            }
            return result!
        }

        set {
            let oldValue = state
            willChangeValue(forKey: newValue.rawValue)
            willChangeValue(forKey: oldValue.rawValue)

            stateQueue.sync { self._state = newValue }

            didChangeValue(forKey: oldValue.rawValue)
            didChangeValue(forKey: newValue.rawValue)
        }
    }

    // MARK: NSOperation
    override dynamic var isReady: Bool {
        return super.isReady && state == .isReady
    }

    override dynamic var isExecuting: Bool {
        return state == .isExecuting
    }

    override dynamic var isFinished: Bool {
        return state == .isFinished
    }

    override var isAsynchronous: Bool {
        return true
    }
}

// MARK: - FetchPhotoOperation Subclass
// This is the more specific subclass that initiates a URLSessionDataTask to retrieve image data
class FetchMediaOperation: ConcurrentOperation {

    // MARK: Properties

    let song: Song
    let songController: SongController
    var mediaData: Data?

    private let session: URLSession

    private var dataTask: URLSessionDataTask?

    init(song: Song, songController: SongController, session: URLSession = URLSession.shared) {
        self.song = song
        self.songController = songController
        self.session = session
        super.init()
    }

    override func start() {
        state = .isExecuting

        guard let url = song.image else { return }

        let task = session.dataTask(with: url) { (data, response, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            if let error = error {
                NSLog("Error fetching data for \(self.song): \(error)")
                return
            }

            guard let data = data else {
                NSLog("No data returned from fetch media operation data task.")
                return
            }

            self.mediaData = data
        }
        task.resume()
        dataTask = task
    }

    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
}
