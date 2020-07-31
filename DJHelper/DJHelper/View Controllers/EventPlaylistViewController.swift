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
    case searched
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
    var searchResults: [Song] = []
    var myAlert = CustomAlert()
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

    @IBAction func viewHostDetail(_ sender: UIButton) {
        guard let currentHost = currentHost else { return }

        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let hostProfileVC = storyboard.instantiateViewController(identifier: "HostProfile") as! HostProfileViewController
        hostProfileVC.currentHost = currentHost
        hostProfileVC.isGuest = true
        present(hostProfileVC, animated: true, completion: nil)
//        self.navigationController?.present(hostProfileVC, animated: true, completion: nil)
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
            let longDate = longDateToString(with: eventDate)
            let time = timeToString(with: eventDate)
            dateLabel.textColor = UIColor(named: "PurpleColor")
            dateLabel.text = String("\(longDate) ▪︎ \(time)")
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
                    return UIColor(named: "PurpleColor")!
                default:
                    return UIColor(named: "customTextColor")!
                }
            }()
        ])

        let setlistButtonTitle = NSMutableAttributedString(string: "Setlist", attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 18)!,
            NSAttributedString.Key.foregroundColor: {
                switch self.currentSongState {
                case .setListed:
                    return UIColor(named: "PurpleColor")!
                default:
                    return UIColor(named: "customTextColor")!
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

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchTerm = searchBar.text,
            searchTerm != "" else { return }
        songController.searchForSong(withSearchTerm: searchTerm) { (results) in
            switch results {
            case let .success(songResults):
                DispatchQueue.main.async {
                    for song in songResults {
                        let newSong = Song(artist: song.artist, externalURL: song.externalURL, songId: song.songId, songName: song.songName)
                        self.searchResults.append(newSong)
                    }
                    self.currentSongState = .searched
                    self.tableView.reloadData()
                }
            case .failure:
                DispatchQueue.main.async {
                    self.myAlert.showAlert(with: "No songs fetched", message: "There we no songs found with that search description.", on: self)
                }
            }
        }
    }

    func longDateToString(with date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy"
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
        case .searched:
            return searchResults.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as? SongDetailTableViewCell else { return UITableViewCell() }

        switch currentSongState {
        case .requested:
            let song = requestedSongs[indexPath.row]
            cell.song = song
        case .setListed:
            let song = setListedSongs[indexPath.row]
            cell.song = song
        case .searched:
            let song = searchResults[indexPath.row]
            cell.song = song
        }

        return cell
    }
}
