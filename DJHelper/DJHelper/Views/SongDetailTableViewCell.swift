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
        print("upvote song button pressed")
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
        print("add song button pressed")
        guard let songController = songController else { return }

        //call this function if its the guest - the host doesn't add song to request list, he adds it to the playlist
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
            if isGuest == true {
                updateGuestRequestsViews()
            } else {
                updateHostRequestsViews()
            }
        case .none:
            voteCountLabel.isHidden = false
            addSongButton.isHidden = true
            upvoteSongButton.isHidden = false
        case .setListed:
            if isGuest == true {
                updateGuestSetlistViews()
            } else {
                updateHostSetlistViews()
            }
        case .searched:
            if isGuest == true {
                updateGuestSearchViews()
            } else {
                updateHostSearchViews()
            }
        }
    }

    // MARK: - Updateviews Methods
    /// Guest should see request list and be able to upvote the song and see it's vote count
    func updateGuestRequestsViews() {
        addSongButton.isHidden = true
        upvoteSongButton.isHidden = false
        voteCountLabel.isHidden = false
    }

    /// Hosts should be able to see votes and add/remove to setlist
    func updateHostRequestsViews() {
        addSongButton.isHidden = false
        upvoteSongButton.isHidden = true
        voteCountLabel.isHidden = false
    }

    /// Guest should only be able to see the song on the setlist and it's voteCount
    func updateGuestSetlistViews() {
    voteCountLabel.isHidden = false
    upvoteSongButton.isHidden = true
    addSongButton.isHidden = true
    }

    /// Host should be able to see votes of song on setlist and remove it from list
    func updateHostSetlistViews() {
        addSongButton.isHidden = true
        upvoteSongButton.isHidden = true
        voteCountLabel.isHidden = false
    }

    ///Guest should be able to only add the song to the request list
    func updateGuestSearchViews() {
        addSongButton.isHidden = false
        upvoteSongButton.isHidden = true
        voteCountLabel.isHidden = true
    }

    /// Host should be able to search for a song and add it to the SetList
    func updateHostSearchViews() {
        addSongButton.isHidden = false
        upvoteSongButton.isHidden = true
        voteCountLabel.isHidden = true
    }
}
