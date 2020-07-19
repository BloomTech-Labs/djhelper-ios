//
//  EventPageViewController.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/11/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit
import MessageUI
import CoreData

class EventPageViewController: UIViewController, UISearchBarDelegate {

    // MARK: - Properties
    var event: Event? {
        didSet {
            loadViewIfNeeded()
            updateViews()
        }
    }

    var hostController: HostController?

    // If a currentHost is not passed in, hide the UI elements designed for a Host.
    var currentHost: Host?
    var eventController: EventController?
    var songController = SongController()
    var currentSongState: SongState = .requested
    var requestedSongs: [Song] = []
    var setListedSongs: [Song] = []
    private let refreshControl = UIRefreshControl()

    // MARK: - IBOutlets
    @IBOutlet weak var eventNameLabel: UILabel!
    @IBOutlet weak var eventDescriptionLabel: UILabel!
    @IBOutlet weak var eventTypeLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var eventImage: UIImageView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet weak var setListButtonProperties: UIButton!
    @IBOutlet weak var requestButtonProperties: UIButton!
    @IBOutlet var leftRequestSetlistButton: UIButton!
    @IBOutlet var rightRequestSetlistButton: UIButton!

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

//        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self

        tableView.keyboardDismissMode = .onDrag
        tableView.refreshControl = refreshControl

//        refreshControl.addTarget(self, action: #selector(refreshSongData(_:)), for: .valueChanged)

        updateViews()
        updateSongList()

        let tapToDismiss = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapToDismiss)
    }

    // MARK: - IBActions
    @IBAction func requestButtonSelected(_ sender: UIButton) {
        currentSongState = .requested
        updateViews()
    }

    @IBAction func setlistButtonSelected(_ sender: UIButton) {
        currentSongState = .setListed
        updateViews()
    }

    @IBAction func shareLinkButtonTapped(_ sender: UIBarButtonItem) {
        guard let passedInEvent = event else {
            print("No event passed to the EventpageVC.\nError on line: \(#line) in function: \(#function)\n")
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
//    @objc func refreshSongData(_ sender: Any) {
//        updateSongList()
//    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // code to search for song
    }

    // MARK: - Private functions
    func updateSongList() {
        // call to the server for songs in event playlist or requested songs
        // set the returned results to some variable
        // filter that variable based on inSetList bool
//        let fetchRequest: NSFetchRequest<Song> = Song.fetchRequest()
//        let predicate = NSPredicate(format: "event.eventID == %i", self.event!.eventID)
//        fetchRequest.predicate = predicate
//        var fetchedSongs: [Song]?
//        let moc = CoreDataStack.shared.mainContext
//        moc.performAndWait {
//            fetchedSongs = try? fetchRequest.execute()
//        }
//        self.refreshControl.endRefreshing()
    }

    private func updateViews() {
        guard let event = event, let name = event.name, let description = event.eventDescription, let type = event.eventType else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return }

        eventNameLabel.text = "Event Name: \(name)"
        eventDescriptionLabel.text = "Description of event: \(description)"
        eventTypeLabel.text = "Event Type: \(type)"

        if let eventDate = event.eventDate {
            dateLabel.text = "Date: \(longDateToString(with: eventDate))"
            timeLabel.text = timeToString(with: eventDate)
        }
        setListButtonProperties.titleLabel?.font = UIFont(name: "Helvetica Neue", size: 18)!
        setListButtonProperties.setTitleColor(.systemBlue, for: .normal)
    }

    private func longDateToString(with date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d, yyyy"
        return formatter.string(from: date)
    }

    private func timeToString(with date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "eventDetailsSegue" {
            guard let eventDetailVC = segue.destination as? CreateEventViewController else { return }

            eventDetailVC.currentHost = currentHost
            eventDetailVC.event = event
            eventDetailVC.eventController = eventController
        }
    }
}

// MARK: - Table View Data Source
extension EventPageViewController: UITableViewDataSource {
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
