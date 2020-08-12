//
//  SongDetailTableViewCell.swift
//  DJHelper
//
//  Created by Craig Swanson on 7/29/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class SongDetailTableViewCell: UITableViewCell {

    var currentSongState: SongState? {
        didSet {
//            updateViews()
        }
    }
    var songController: SongController?
    var song: Song? {
        didSet {
            updateViews()
        }
    }

    @IBOutlet var songLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var coverArtImageView: UIImageView!
    @IBOutlet var voteCountLabel: UILabel!
    @IBOutlet var addSongButton: UIButton!
    @IBOutlet var upvoteSongButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    @IBAction func requestSong(_ sender: UIButton) {
        guard let song = song else { return }
        if addSongButton.isSelected {
            addSongRequest(song)
        } else {
            cancelSongRequest(song)
        }
        addSongButton.isSelected.toggle()

    }

    @IBAction func upvoteSong(_ sender: UIButton) {
        guard let song = song else { return }
        if upvoteSongButton.isSelected {
            addUpvoteSong(song)
        } else {
            // present an alert verifying intention to cancel upvote
            cancelUpvoteSong(song)
        }
        upvoteSongButton.isSelected.toggle()
    }

    func addSongRequest(_ song: Song) {
        guard let songController = songController else { return }

        songController.addSongToRequest(song) { (result) in
            // I think the addSongToRequest might need to be modified
            // it takes a song, but we need to verify that the song
            // that it's taking includes the correct trackID for the backend
        }
    }

    func cancelSongRequest(_ song: Song) {
        // Insert network call here to delete the existing request
    }

    func addUpvoteSong(_ song: Song) {
        // Insert network call here to upvote a song
    }

    func cancelUpvoteSong(_ song: Song) {
        // Insert network call here to cancel the upvote request
    }

    func updateViews() {
        guard let song = song,
        let songController = songController else { return }

        // TODO: Move this network call from the cell
        if let coverArtURL = song.image {
            songController.fetchCoverArt(url: coverArtURL) { (result) in
                switch result {
                case let .success(image):
                    DispatchQueue.main.async {
                        self.coverArtImageView.image = image
                    }
                case .failure:
                    DispatchQueue.main.async {
                        self.coverArtImageView.image = #imageLiteral(resourceName: "musicSymbol")
                    }
                }
            }
        }

        songLabel.text = song.songName
        artistLabel.text = song.artist

        switch currentSongState {
        case .requested:
            voteCountLabel.isHidden = false
            // on song states where voteCountLabel is visible, network call to update the vote count?
            addSongButton.isHidden = true
            upvoteSongButton.isHidden = false
        case .none:
            voteCountLabel.isHidden = false
            addSongButton.isHidden = true
            upvoteSongButton.isHidden = false
        case .setListed:
            voteCountLabel.isHidden = false
            upvoteSongButton.isHidden = true
            addSongButton.isHidden = true
        case .searched:
            voteCountLabel.isHidden = true
            upvoteSongButton.isHidden = true
            addSongButton.isHidden = false
        }
    }
}

    // TODO: Move the following code to the song controller. Here temporarily in order to stay out of other files
extension SongController {
    func fetchCoverArt(url: URL, completion: @escaping (Result<UIImage, SongError>) -> ()) {
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
