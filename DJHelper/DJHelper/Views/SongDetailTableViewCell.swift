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
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func requestSong(_ sender: UIButton) {
        addSongButton.isSelected.toggle()
    }

    func updateViews() {
        guard let song = song else { return }

        coverArtImageView.image = #imageLiteral(resourceName: "musicSymbol")
        songLabel.text = song.songName
        artistLabel.text = song.artist

        switch currentSongState {
        case .requested:
            voteCountLabel.isHidden = false
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
