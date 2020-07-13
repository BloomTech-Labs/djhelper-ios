//
//  EventPlaylistViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 6/8/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

// enum is a state indicator, and the basis of the table view data source
enum SongState {
    case requested
    case setListed
}

class EventPlaylistViewController: UIViewController, UISearchBarDelegate {

    // MARK: - Properties
    var event: Event?
    var currentHost: Host?
    var currentSongState: SongState = .requested
    var requestedSongs: [Song] = []
    var setListedSongs: [Song] = []
    private let refreshControl = UIRefreshControl()

    // MARK: - Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var eventImage: UIImageView!
    @IBOutlet var eventNameLabel: UILabel!
    @IBOutlet var eventDescriptionLabel: UILabel!
    @IBOutlet var hostNameButton: UIButton!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        tableView.keyboardDismissMode = .onDrag
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshSongData(_:)), for: .valueChanged)

        updateViews()
        updateSongList()
    }

    // MARK: - Methods
    @objc func refreshSongData(_ sender: Any) {
        updateSongList()
    }

    func updateSongList() {
        // call to the server for songs in Event
        // set the returned results to some variable
        // filter that variable based on inSetList bool
        self.refreshControl.endRefreshing()
    }
    private func updateViews() {
        guard let event = event,
            let currentHost = currentHost else { return }

        eventNameLabel.text = event.name
        eventDescriptionLabel.text = event.eventDescription
        hostNameButton.titleLabel?.text = currentHost.name
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // code to search for song
    }
}

extension EventPlaylistViewController: UITableViewDataSource {
    // perform GET to retrieve all Song entries for the Event
    // when in "set list" mode, filter for songs with inSetList set to true;
    // when in "requests" mode, inSetList is false.
    // currently, how a guest makes a request is not in the UX design
    // presumably, a request would POST a Song to the server
    // an upvote should PUT the upvote data to the server for the specific Song
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch currentSongState {
        case .requested:
            return requestedSongs.count
        case .setListed:
            return setListedSongs.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)

        switch currentSongState {
        case .requested:
            let song = requestedSongs[indexPath.row]
        case .setListed:
            let song = setListedSongs[indexPath.row]
        }
        // Create custom cell Swift file and pass song into the cell

        return cell
    }
}

// Temporary song struct to use for the data source calls
//struct Song {
//    let artist: String
//    let songName: String
//    var upVotes: Int
//    var inSetList: Bool
//}
