//
//  EventPlaylistViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 6/8/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit
import CoreData

// enum is a state indicator, and the basis of the table view data source
enum SongState {
    case requested
    case setListed
}

class EventPlaylistViewController: UIViewController, UISearchBarDelegate {

    // MARK: - Properties
    var event: Event?
    var currentHost: Host?
    var hostController: HostController?
    var eventController: EventController?
    var songController = SongController()
    var currentSongState: SongState = .requested
    var isGuest: Bool = false
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
    @IBOutlet var leftRequestSetlistButton: UIButton!
    @IBOutlet var rightRequestSetlistButton: UIButton!

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

    // MARK: - Actions
    @IBAction func requestButtonSelected(_ sender: UIButton) {
        currentSongState = .requested
        updateViews()
    }

    @IBAction func setlistButtonSelected(_ sender: UIButton) {
        currentSongState = .setListed
        updateViews()
    }

    // MARK: - Methods
    @objc func refreshSongData(_ sender: Any) {
        updateSongList()
    }

    func updateSongList() {
        // call to the server for songs in event playlist or requested songs
        // set the returned results to some variable
        // filter that variable based on inSetList bool
        let fetchRequest: NSFetchRequest<Song> = Song.fetchRequest()
        let predicate = NSPredicate(format: "event.eventID == %i", self.event!.eventID)
        fetchRequest.predicate = predicate
        var fetchedSongs: [Song]?
        let moc = CoreDataStack.shared.mainContext
        moc.performAndWait {
            fetchedSongs = try? fetchRequest.execute()
        }
        self.refreshControl.endRefreshing()
    }
    
    private func updateViews() {
        guard let event = event,
            let currentHost = currentHost else { return }

        eventNameLabel.text = event.name
        eventDescriptionLabel.text = event.eventDescription

        if let eventDate = event.eventDate {
            dateLabel.text = longDateToString(with: eventDate)
            timeLabel.text = timeToString(with: eventDate)
        }

        let buttonTitle = NSMutableAttributedString(string: "\(currentHost.name ?? "EventHost")", attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 14)!,
            NSAttributedString.Key.foregroundColor: UIColor.systemBlue
        ])
        hostNameButton.setAttributedTitle(buttonTitle, for: .normal)

        // udpateViews() should also swap the location of the
        // Setlist and Requests buttons based on the value of isGuest
        let requestButtonTitle = NSMutableAttributedString(string: "Requests", attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 18)!,
            NSAttributedString.Key.foregroundColor: {
                switch self.currentSongState {
                case .requested:
                    return UIColor.systemBlue
                case .setListed:
                    return UIColor(named: "customTextColor")!
                }
            }()
        ])

        let setlistButtonTitle = NSMutableAttributedString(string: "Setlist", attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 18)!,
            NSAttributedString.Key.foregroundColor: {
                switch self.currentSongState {
                case .requested:
                    return UIColor(named: "customTextColor")!
                case .setListed:
                    return UIColor.systemBlue
                }
            }()
        ])
        if isGuest {
            self.leftRequestSetlistButton.setAttributedTitle(requestButtonTitle, for: .normal)
            self.rightRequestSetlistButton.setAttributedTitle(setlistButtonTitle, for: .normal)
        } else {
            self.leftRequestSetlistButton.setAttributedTitle(setlistButtonTitle, for: .normal)
            self.rightRequestSetlistButton.setAttributedTitle(requestButtonTitle, for: .normal)
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // code to search for song
    }

    func longDateToString(with date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }

    func timeToString(with date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Table View Data Source
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

// this was added to test the playlist view controller with mock song data
//        let moc = CoreDataStack.shared.mainContext
//        moc.performAndWait {
//
//            let song1 = Song(artist: "song1 Artist", songID: 1111111, songName: "song1 Name")
//            let song2 = Song(artist: "song2 Artist", songID: 2222222, songName: "song2 Name")
//            let song3 = Song(artist: "song3 Artist", songID: 3333333, songName: "song3 Name")
//            let event456 = Event(name: "mock event", eventType: "test", eventDescription: "test of playlist", eventDate: Date(), hostID: 30, eventID: 456)
//            song1.addToEvents(event456)
//            song2.addToEvents(event456)
//            song3.addToEvents(event456)
//            do {
//                try? CoreDataStack.shared.save()
//            }
//        }
