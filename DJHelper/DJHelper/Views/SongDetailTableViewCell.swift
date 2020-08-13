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
    var eventID: Int32 = 0
    var trackRequestRepresentation: TrackRequest?
    var song: Song? {
        didSet {
            updateViews()
        }
    }
    var isGuest: Bool? {
        didSet {
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
        guard let song = song,
            let requestedSongConstant: TrackRequest = song.songToTrackRequest  else { return }
        trackRequestRepresentation = requestedSongConstant
        trackRequestRepresentation!.eventId = eventID
        print(trackRequestRepresentation)
        if addSongButton.isSelected {
            cancelSongRequest(trackRequestRepresentation!)
        } else {
            addSongRequest(trackRequestRepresentation!)
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

    func addSongRequest(_ song: TrackRequest) {
        guard let songController = songController else { return }

        songController.addSongToRequest(song) { (result) in
            switch result {
            case .success:
                break
            case let .failure(error):
                print("Error adding song request: \(error)")
            }
        }
    }

    func cancelSongRequest(_ song: TrackRequest) {
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
        // for the dj view the dj should see the plus button in the cell and consequently adds that song to the setlist
        
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
        if trackRequestRepresentation?.eventId == 0 {
            addSongButton.isSelected = false
        }

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
