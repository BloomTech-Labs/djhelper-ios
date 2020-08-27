//
//  SongDetailTableViewCell.swift
//  DJHelper
//
//  Created by Craig Swanson on 7/29/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

/*
 The SongDetailTableViewCell has several possible states depending on the user
 1. Guest
 2. Host
 And depending on the "state" the user is in
 1. Searching for a song (.searched)
 2. Viewing the request list (.requested)
 3. Viewing the set list (.setListed)
 */
class SongDetailTableViewCell: UITableViewCell {

    // MARK: - Properties
    var currentSongState: SongState?
    var songController: SongController?
    var eventID: Int32 = 0
    var trackRequestRepresentation: TrackRequest?
    var song: Song? {
        didSet {
            updateViews()
        }
    }
    var isGuest: Bool?

    // MARK: - Outlets
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

    override func prepareForReuse() {
        super.prepareForReuse()

        // the checkmark icon is set to not selected by default;
        // the code then checks the boolean in the model to see if it should be selected and displays it accordingly.
        // this was done in order to avoid incorrect states in the checkmark icon state (selected when it shouldn't be)
        addSongButton.isSelected = false
    }

    // MARK: - Actions
    @IBAction func requestSong(_ sender: UIButton) {
        print("requestSong button pressed")
        guard let song = song,
            let requestedSongConstant: TrackRequest = song.songToTrackRequest  else { return }
        trackRequestRepresentation = requestedSongConstant

        // this line is where we set the eventID for the request sent to the server
        trackRequestRepresentation!.eventId = eventID

        if addSongButton.isSelected {
            cancelSongRequest(trackRequestRepresentation!)
        } else {
            // if the user is a guest, then simply add song to to request list
            // if the user is a host, then either add song to request list (if state equals .searched)
            // or add the song to the play list (if the state is not .searched)
            if isGuest == true {
                guestAddsSongToRequestList(trackRequestRepresentation!)
            } else {
                guard let currentSongState = currentSongState else { return }
                if currentSongState == .searched {
                    guestAddsSongToRequestList(trackRequestRepresentation!)
                } else {
                    hostAddsSongToPlaylist(song)
                }
            }
        }
        addSongButton.isSelected.toggle()
        self.song?.inSetList.toggle()  // the "inSetList" property was repurposed to reflect the intended state of the checkmark icon. It is not for the setList.
    }

    // MARK: - Methods
    /**
     Calls the addSongToRequest() method in SongController with the cell's current song

     - Parameter song: The cell's song
     */
    func guestAddsSongToRequestList(_ song: TrackRequest) {
        print("guest added song to request list")
        guard let songController = songController else { return }

        //call this function if its the guest
        // also call it as an intermediate step when the host is moving a song
        // from the search results list to the set list -- if the song state is .searched
        // then it completes the second step of adding the song to the playlist
            songController.addSongToRequest(song) { (result) in
                switch result {
                case let .success(trackresponse):
                    guard let songState = self.currentSongState else { return }
                    if songState == .searched {
                        guard self.song != nil else { return }
                        var song = self.song
                        song?.songID = trackresponse.trackId
                        self.hostAddsSongToPlaylist(song!)
                    }
                case let .failure(error):
                    print("Error adding song request: \(error)")
                }
            }
    }

    /**
     Calls the addSongToPlaylist() method in SongController with the cell's current song

     - Parameter song: The cell's current song
     */
    func hostAddsSongToPlaylist(_ song: Song) {
        songController?.addSongToPlaylist(song: song, completion: { (results) in
            switch results {
            case let .success((success)):
                print("Host successfully added requested song to playlist: \(success)")
            case let .failure(error):
                print("""
                    Error on line: \(#line) in function: \(#function)\n
                    Readable error: \(error.localizedDescription)\n Technical error: \(error)
                    """)
            }
        })
    }

    // MARK: - Update Views
    func updateViews() {
        guard let song = song else { return }
        songLabel.text = song.songName
        artistLabel.text = song.artist

        // The eventID property will be 0 until the song is requested
        if trackRequestRepresentation?.eventId == 0 {
            addSongButton.isSelected = false
        }

        // Setting the status of the cell's button after the cell is reused by the table view. The inSetList property keeps track of the state.
        if song.inSetList {
            addSongButton.isSelected = true
        } else {
            addSongButton.isSelected = false
        }

        // The switch looks at the three states and then whether the current user is a guest or host.
        // This decides the method to be run that will set the appropriate UI
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

    // setImage is called from outside the cell to set the album artwork image
    func setImage(_ image: UIImage?) {
        coverArtImageView.image = image
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
        print("host setlist shouldnt show add button")
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

    // MARK: - Unimplemented Methods
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

    func cancelSongRequest(_ song: TrackRequest) {
        // Insert network call here to delete the existing request
    }

    func addUpvoteSong(_ song: Song) {
        // Insert network call here to upvote a song
    }

    func cancelUpvoteSong(_ song: Song) {
        // Insert network call here to cancel the upvote request
    }
}

