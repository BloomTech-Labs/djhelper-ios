//
//  EventPlaylistViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 6/8/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class EventPlaylistViewController: UIViewController, UISearchBarDelegate {

    // MARK: - Properties
    var event: Event?
    var currentHost: Host?
    var songs: [Song] = []
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
    }

    // MARK: - Methods
    @objc func refreshSongData(_ sender: Any) {
        updateSongList()
    }

    func updateSongList() {
        // call to the server for songs in Event
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath)
        
        let song = songs[indexPath.row]
        // Create custom cell Swift file and pass song into the cell
        
        return cell
    }


}


// Temporary song struct to use for the data source calls
struct Song {
    let artist: String
    let songName: String
    var upVotes: Int
}
