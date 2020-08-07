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
    var hostController: HostController?
    var isGuest: Bool?
    let todaysDate = Date().stringFromDate()
    var eventsHappeningNow: [Event]?
    var upcomingEvents: [Event]? {
        didSet {
            let barViewControllers = self.tabBarController?.viewControllers
            guard let newEventNC = barViewControllers?[2] as? UINavigationController else { return }
            if let newEventVC = newEventNC.viewControllers.first as? NewEventViewController {
                newEventVC.hostEventCount = self.upcomingEvents?.count ?? 0
            }
        }
    }
    var pastEvents: [Event]?
    var allEvents: [Event] = []
    var upcomingEventsVC = UpcomingEventsViewController()
    var pastEventsVC = PastEventsViewController()
    var hostingEventsVC = HostingEventsViewController()

    // MARK: - IBOutlets
//    @IBOutlet weak var upcomingShowsCollectionView: UICollectionView!
//    @IBOutlet weak var hostingEventCollectionView: UICollectionView!
//    @IBOutlet weak var pastEventsCollectionView: UICollectionView!

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchEventsFromServer()
        let barViewControllers = self.tabBarController?.viewControllers
        guard let profileVC = barViewControllers?[1] as? HostProfileViewController else { return }
        profileVC.currentHost = self.currentHost
        profileVC.hostController = self.hostController
        guard let newEventNC = barViewControllers?[2] as? UINavigationController else { return }
        if let newEventVC = newEventNC.viewControllers.first as? NewEventViewController {
            newEventVC.eventController = self.eventController
            newEventVC.hostController = self.hostController
            newEventVC.currentHost = self.currentHost
            newEventVC.hostEventCount = self.upcomingEvents?.count ?? 0
        }
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
                        let hostEvents = self.fetchRequest()
                        guard hostEvents.count != 0 else { return }
                        self.sortEvents(events: hostEvents)
                      }
                  case .failure:
                      return
                  }
              }
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

        pastEvents = events.filter { $0.eventDate! < Date() }
        pastEventsVC.pastEvents = self.pastEvents

        upcomingEvents = events.filter { $0.eventDate! > Date() }
        upcomingEventsVC.upcomingEvents = self.upcomingEvents

        if let upcomingEvents = upcomingEvents {
            for event in upcomingEvents {
                allEvents.append(event)
            }
        }
        if let pastEvents = pastEvents {
            for event in pastEvents {
                allEvents.append(event)
            }
        }
        hostingEventsVC.hostingEvents = self.allEvents
    }

    // This action unwinds from the create new event tab after a new event is created.
    @IBAction func unwindToEventList(segue: UIStoryboardSegue) {
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UpcomingEventsSegue" {
            guard let destinationVC = segue.destination as? UpcomingEventsViewController else { return }
            self.upcomingEventsVC = destinationVC
        } else if segue.identifier == "PastEventsSegue" {
            guard let destinationVC = segue.destination as? PastEventsViewController else { return }
            self.pastEventsVC = destinationVC
        } else if segue.identifier == "HostingEventsSegue" {
            guard let destinationVC = segue.destination as? HostingEventsViewController else { return }
            self.hostingEventsVC = destinationVC
        }
    }
}
