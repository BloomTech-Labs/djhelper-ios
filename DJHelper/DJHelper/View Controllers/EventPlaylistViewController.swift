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

class EventPlaylistViewController: ShiftableViewController, UISearchBarDelegate {

    // MARK: - Properties
    var event: Event?
    var currentHost: Host?
    var hostController: HostController?
    var eventController: EventController?
    var songController = SongController()
    var currentSongState: SongState = .requested
    let activityIndicatorView = UIActivityIndicatorView(style: .large)
    var isGuest: Bool = false
    var requestedSongs: [Song] = []
    var setListedSongs: [Song] = []
    var searchResults: [Song] = []
    var myAlert = CustomAlert()
    private var operations = [String: Operation]()
    private let cache = Cache<String, Data>()
    private let photoFetchQueue = OperationQueue()
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
    @IBOutlet weak var shareButtonProperties: UIBarButtonItem!

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        searchBar.delegate = self
        tableView.keyboardDismissMode = .onDrag

        // code for pull-to-refresh
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshSongData(_:)), for: .valueChanged)

        fetchRequestList()
        updateViews()
        updateSongList()

        let tapToDismiss = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapToDismiss)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }

    /**
     Calls the fetchAllTracksFromRequestList(forEventID:) method from SongController. Displays current list of request songs if successful.
     */
    private func fetchRequestList() {
        guard let event = event else { return }
        //Guest view: Should return a Song model for upvoting
        songController.fetchAllTracksFromRequestList(forEventId: Int(event.eventID)) { (result) in
            switch result {
            case let .success(requestedSongs):
                DispatchQueue.main.async {
                    self.requestedSongs = requestedSongs
                    self.tableView.reloadData()
                }
            case let .failure(error):
                print("Error in fetching all requested songs: \(error)")
            }
        }
    }

    ///To dismiss the custom alert
    @objc func dismissAlert() {
        myAlert.dismissAlert()
    }

    // MARK: - Actions
    @IBAction func requestButtonSelected(_ sender: UIButton) {
        // when a guest is viewing, this is the request button
        // when a host/DJ is viewing, this is the add-to-set-list button
        print("request button pressed as guest: \(isGuest)")
        if isGuest {
            currentSongState = .requested
            fetchRequestList()
            updateViews()
        } else {
            currentSongState = .setListed
            fetchSetlist()
            updateViews()
        }
    }

    @IBAction func setlistButtonSelected(_ sender: UIButton) {
        // when a guest is viewing, this is the setlist button
        // when a host/DJ is viewing, this is the request button
        if isGuest {
            currentSongState = .setListed
            fetchSetlist()
            updateViews()
        } else {
            currentSongState = .requested
            fetchRequestList()
            updateViews()
        }
    }

    // Instantiate a HostProfileViewController that shows details of the current Host.
    @IBAction func viewHostDetail(_ sender: UIButton) {
        guard let currentHost = currentHost else { return }
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let hostProfileVC = storyboard.instantiateViewController(identifier: "HostProfile") as! HostProfileViewController
        hostProfileVC.currentHost = currentHost
        hostProfileVC.isGuest = true
        present(hostProfileVC, animated: true, completion: nil)
    }

    // If shareEventButton is tapped, create and instance of UIActivityViewController and pass the message and the URL with the current eventID
    @IBAction func shareEventButtonPressed(_ sender: UIBarButtonItem) {
        guard let passedInEvent = event, let eventDate = passedInEvent.eventDate else {
            print("No event passed to the EventPlaylistVC.\nError on line: \(#line) in function: \(#function)\n")
            return
        }
        guard eventDate > Date() else {
            print("Event has already passed. Error on line: \(#line) in function: \(#function)\n")
            return
        }

        print("eventId to pass with link: \(passedInEvent.eventID)")

        let message = "Hey! Please check out this new event I created!"
        let tempUrlToPass = URL(string: "djscheme://www.djhelper.com/guestLogin?eventId=\(passedInEvent.eventID)")!
        let objectsToShare: [Any] = [message, tempUrlToPass]

        let activityController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        present(activityController, animated: true, completion: nil)
    }

    // MARK: - Methods
    // Method called in the pull-to-refresh code.
    @objc func refreshSongData(_ sender: Any) {
        updateSongList()
    }

    /**
     Completes a Core Data fetch of songs associated with the current eventID.
     */
    func updateSongList() {
        // I am not sure the results of this fetch request are actually being used.
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
        // TODO: - defaults to currentHost holding value -shouldn't happen
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

        // Per the UX design, udpateViews() should also swap the location of the
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
            self.shareButtonProperties.isEnabled = false
        } else {
            self.leftRequestSetlistButton.setAttributedTitle(setlistButtonTitle, for: .normal)
            self.rightRequestSetlistButton.setAttributedTitle(requestButtonTitle, for: .normal)
            self.shareButtonProperties.isEnabled = true
        }
        tableView.reloadData()
    }

    /**
     Calls the fetchSetlistFromServer(for:) method from SongController. Displays current list of songs in the set list if successful.
     */
    func fetchSetlist() {
        guard let event = event else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return
        }
        songController.fetchSetlistFromServer(for: event) { (results) in
            switch results {
            case let .success(songs):
                DispatchQueue.main.async {
                    print("songs returned from fetchsetlistfromserver: \(songs.count)")
                    self.setListedSongs = songs
                    self.tableView.reloadData()
                }
            case let .failure(error):
                DispatchQueue.main.async {
                    print("""
                        Error on line: \(#line) in function: \(#function)\n
                        Readable error: \(error.localizedDescription)\n Technical error: \(error)
                        """)
                }
            }
        }
    }

    // MARK: - Search for Song
    // The following method is used by the UISearchBarDelegate
    // When the search bar is active and Return is tapped, the contents of the search
    // bar are used as the search term for a network call.
    // The search term is passed to the searchForSong(withSearchTerm:) method in SongController
    // If successful, the JSON is converted into an array of Song and displayed in the table view.
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let event = event,
            let searchTerm = searchBar.text,
            searchTerm != "" else { return }
        searchResults = []
        self.activityIndicator(activityIndicatorView: activityIndicatorView, shouldStart: true)
        songController.searchForSong(withSearchTerm: searchTerm) { (results) in
            switch results {
            case let .success(songResults):
                DispatchQueue.main.async {
                    for song in songResults {
                        let newSong = Song(artist: song.artist, externalURL: song.externalURL, songId: song.songId, songName: song.songName,
                                           preview: song.preview,
                                           image: song.image)
                        newSong.event = event
                        self.searchResults.append(newSong)
                    }
                    self.currentSongState = .searched
                    self.tableView.reloadData()
                    self.activityIndicator(activityIndicatorView: self.activityIndicatorView, shouldStart: false)
                }
            case .failure:
                DispatchQueue.main.async {
                    self.activityIndicator(activityIndicatorView: self.activityIndicatorView, shouldStart: false)
                    self.myAlert.showAlert(with: "No songs fetched", message: "There we no songs found with that search description.", on: self)
                }
            }
        }
    }

    // MARK: - Load Cover Art Image
    /**
     Uses block operations to fetch cover art images on a background queue and then store the data in a cache for more responsive scrolling with a large number of images

     - Parameter songCell: the current SongDetailTableViewCell
     - Parameter indexPath: the index path of the current cell
     */
    func loadImage(for songCell: SongDetailTableViewCell, forItemAt indexPath: IndexPath) {
        // create a storage location for the current song
        var currentSong = Song()

        // get the current song based on its index path and the currentSongState
        switch currentSongState {
        case .requested:
            currentSong = requestedSongs[indexPath.row]
        case .setListed:
            currentSong = setListedSongs[indexPath.row]
        case .searched:
            currentSong = searchResults[indexPath.row]
        }

        // if the song is already in cache, then used the cached data to set the cover art UIImage and reload the cell.
        guard let songId = currentSong.songId else { return }
        if let coverArtData = cache.value(for: songId),
            let image = UIImage(data: coverArtData) {
            songCell.setImage(image)
            self.tableView.reloadRows(at: [indexPath], with: .automatic)
            return
        }

        // if the song is not in cache, set up a block operation using the custom Operation subclass to fetch the image data on a background queue.
        let fetchOp = FetchMediaOperation(song: currentSong, songController: songController)
        let cacheOp = BlockOperation {
            if let data = fetchOp.mediaData {
                // when data is returned, put it in the cache for that songId
                self.cache.cache(value: data, for: songId)
                DispatchQueue.main.async {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }

        let completionOp = BlockOperation {
            defer { self.operations.removeValue(forKey: songId) }

            if let currentIndexPath = self.tableView.indexPath(for: songCell),
                currentIndexPath != indexPath {
                print("Got image for a now-reused cell")
                return
            }

            // if the cell is still visible then set its imageView with the data returned
            if let data = fetchOp.mediaData {
                songCell.setImage(UIImage(data: data))
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }

        cacheOp.addDependency(fetchOp)
        completionOp.addDependency(fetchOp)

        photoFetchQueue.addOperation(fetchOp)
        photoFetchQueue.addOperation(cacheOp)
        OperationQueue.main.addOperation(completionOp)

        operations[songId] = fetchOp

    }

    /**
     Creates a custom date format for the event's date label.

     - Parameter date: The event's date
     - Returns: A string with a custom date format for the UI
     */
    func longDateToString(with date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d, yyyy"
        return formatter.string(from: date)
    }

    /**
     Creates a custom time format for the event's time label.

     - Parameter date: The event's date
     - Returns: A string with a custom time format for the UI
     */
    func timeToString(with date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}

// MARK: - Table View Data Source
extension EventPlaylistViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    // use the appropriate Song array based on the currentSongState
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SongCell", for: indexPath) as? SongDetailTableViewCell else {
            return UITableViewCell()

        }

        cell.songController = songController
        cell.eventID = event?.eventID ?? 0
        cell.isGuest = self.isGuest
        loadImage(for: cell, forItemAt: indexPath)

        switch currentSongState {
        case .requested:
            cell.currentSongState = .requested
            let song = requestedSongs[indexPath.row]
            cell.song = song
        case .setListed:
            let song = setListedSongs[indexPath.row]
            cell.currentSongState = .setListed
            cell.song = song
        case .searched:
            let song = searchResults[indexPath.row]
            cell.currentSongState = .searched
            cell.song = song
        }
        return cell
    }

    // swipe to delete
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if isGuest == false {
            if editingStyle == .delete {

                switch currentSongState {
                case .requested:
                    let song = requestedSongs[indexPath.row]
                    deleteTrackFromRequestList(song: song)
                case .setListed:
                    let song = setListedSongs[indexPath.row]
                    deleteSongFromSetlist(song: song)
                case .searched:
                    break
                }
            }
        }
    }

    /**
     Calls deleteTrackFromRequests(trackId:) method from SongController. If successful, the song is deleted and table view reloaded.

     - Parameter song: the current cell's song
     */
    func deleteTrackFromRequestList(song: Song) {
        songController.deleteTrackFromRequests(trackId: Int(song.songID)) { (results) in
            switch results {
            case let .success(success):
                DispatchQueue.main.async {
                    self.fetchRequestList()
                    print("success: \(success)")
                }
            case let .failure(error):
                print("""
                    Error on line: \(#line) in function: \(#function)\n
                    Readable error: \(error.localizedDescription)\n Technical error: \(error)
                    """)
                DispatchQueue.main.async {
                    self.myAlert.showAlert(with: "Error deleting song from Request List", message: error.localizedDescription, on: self)
                }
            }
        }
    }

    /**
     Calls deleteTrackFromSetlist(trackId:) method from SongController. If successful, the song is deleted and table view reloaded.

     - Parameter song: the current cell's song
     */
    func deleteSongFromSetlist(song: Song) {
        songController.deleteSongFromPlaylist(song: song) { (results) in
            switch results {
            case let .success(success):
                DispatchQueue.main.async {
                    self.fetchSetlist()
                    print("success: \(success)")
                }
            case let .failure(error):
                print("""
                    Error on line: \(#line) in function: \(#function)\n
                    Readable error: \(error.localizedDescription)\n Technical error: \(error)
                    """)
                DispatchQueue.main.async {
                    self.myAlert.showAlert(with: "Error deleting song from Set List", message: error.localizedDescription, on: self)
                }
            }
        }
    }
}
