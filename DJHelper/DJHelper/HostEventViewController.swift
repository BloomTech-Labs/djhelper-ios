//
//  HostEventViewController.swift
//  DJHelper
//
//  Created by Michael Flowers on 7/29/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit
import CoreData

class HostEventViewController: UIViewController {

    // MARK: - Instance Variables
    var currentHost: Host?
    var eventController: EventController?
    let todaysDate = Date().stringFromDate()
    var eventsHappeningNow: [Event]?
    var upcomingEvents: [Event]?
    var pastEvents: [Event]?
    var allEvents: [Event]?

    // MARK: - IBOutlets
    @IBOutlet weak var upcomingShowsCollectionView: UICollectionView!
    @IBOutlet weak var hostingEventCollectionView: UICollectionView!
    @IBOutlet weak var pastEventsCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEventsFromServer()
    }

    // MARK: - Private Methods
    ///We should be able to fetch from core data but I'm fetching from the server for testing.
    private func fetchEventsFromServer() {
        guard let host = currentHost, let eventController = eventController else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return
        }
        eventController.fetchAllEventsFromServer(for: host) { (results) in
                  switch results {
                  case .success:
                      DispatchQueue.main.async {
                        self.sortEvents(events: self.fetchRequest())
                        self.setDataSourceForCollectionViews()
                      }
                  case .failure:
                      return
                  }
              }
    }

    private func setDataSourceForCollectionViews() {
        upcomingShowsCollectionView.dataSource = self
        hostingEventCollectionView.dataSource = self
        pastEventsCollectionView.dataSource = self
    }

        ///CODE FOR FETCHING FROM CORE DATA
    private func fetchRequest() -> [Event] {
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        var events: [Event]?
        do {
             events = try CoreDataStack.shared.mainContext.fetch(fetchRequest)
        } catch {
            print("""
                Error on line: \(#line) in function: \(#function)\n
                Readable error: \(error.localizedDescription)\n Technical error: \(error)
                """)
            events = []
        }
        print("events: \(events ?? [])")
        return events ?? []
    }

    private func sortEvents(events: [Event]) {
        eventsHappeningNow = events.filter { $0.eventDate == Date() }
        print("Event's happening now: \(String(describing: eventsHappeningNow?.count))")

        pastEvents = events.filter { $0.eventDate! < Date() }
        print("passedEvents: \(String(describing: pastEvents?.count))")

        upcomingEvents = events.filter { $0.eventDate! > Date() }
        print("upcomingEvents: \(String(describing: upcomingEvents?.count))")
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}

extension HostEventViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView {
        case hostingEventCollectionView:
            if let count = eventsHappeningNow?.count {
                return count
            } else {
                return 1
            }
        case upcomingShowsCollectionView:
            if let count = upcomingEvents?.count {
                return count
            } else {
                return 1
            }
        case pastEventsCollectionView:
            if let count = pastEvents?.count {
                return count
            }
            return 1
        default:
            return 20
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionView {
        case hostingEventCollectionView:
           let cell = hostingEventCollectionView.dequeueReusableCell(withReuseIdentifier: "hostingEventsCell",
                                                                     for: indexPath) as! HostEventCollectionViewCell
            return cell
        case upcomingShowsCollectionView:
            let cell = upcomingShowsCollectionView.dequeueReusableCell(withReuseIdentifier: "upcomingShowCell",
                                                                       for: indexPath) as! HostEventCollectionViewCell
            let event = upcomingEvents?[indexPath.row]
            cell.event = event
            return cell
        case pastEventsCollectionView:
            let cell = pastEventsCollectionView.dequeueReusableCell(withReuseIdentifier: "pastEventCell",
                                                                    for: indexPath) as! HostEventCollectionViewCell
            return cell
        default:
            return UICollectionViewCell()
        }
    }
}
