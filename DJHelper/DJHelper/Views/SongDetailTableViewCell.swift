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
            updateViews()
        }
    }

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
        // Insert network call here to request a song
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
        guard let song = song else { return }

        coverArtImageView.image = #imageLiteral(resourceName: "musicSymbol")
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
