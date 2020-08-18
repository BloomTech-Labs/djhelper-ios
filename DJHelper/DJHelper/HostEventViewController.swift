//
//  HostEventViewController.swift
//  DJHelper
//
//  Created by Michael Flowers on 7/29/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit
import CoreData

class HostEventViewController: UIViewController, newEventCreatedDelegate {
    func loadNewEvent() {
        fetchEventsFromServer()
    }


    // MARK: - Instance Variables
    var currentHost: Host?
    var eventController: EventController?
    var hostController: HostController?
    var isGuest: Bool?
    let todaysDate = Date().stringFromDate()
    var eventsHappeningNow: [Event]? {
        didSet {
            happeningNowImageView.image = #imageLiteral(resourceName: "event-default")
            guard let currentEvents = eventsHappeningNow else { return }
            let currentEvent = currentEvents.first
            happeningNowTitleLabel.text = currentEvent?.name
            happeningNowDateLabel.text = currentEvent?.eventDate?.stringFromDate()
        }
    }
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
    @IBOutlet var happeningNowImageView: UIImageView!
    @IBOutlet var happeningNowDateLabel: UILabel!
    @IBOutlet var happeningNowTitleLabel: UILabel!

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
            newEventVC.delegate = self
            newEventVC.hostEventCount = self.upcomingEvents?.count ?? 0
        }
    }

    @IBAction func happeningNowButton(_ sender: UIButton) {
        guard let currentEvents = eventsHappeningNow else { return }
        let currentEvent = currentEvents.first

        guard let eventDetailVC = self.storyboard?.instantiateViewController(identifier: "EventDetailVC") as? EventPlaylistViewController else { return }

        eventDetailVC.event = currentEvent
        eventDetailVC.modalPresentationStyle = .fullScreen
        eventDetailVC.currentHost = currentHost
        eventDetailVC.hostController = hostController
        eventDetailVC.eventController = eventController
        eventDetailVC.isGuest = false
        self.navigationController?.pushViewController(eventDetailVC, animated: true)
    }

    // MARK: - Private Methods
    ///We should be able to fetch from core data but I'm fetching from the server for testing.
    func fetchEventsFromServer() {
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
        // This says that the event date is less than right now but also greater than 5 hours ago
        eventsHappeningNow = events.filter { $0.eventDate! < Date() && $0.eventDate! > Date().addingTimeInterval(-18000) }

        pastEvents = events.filter { $0.eventDate! < Date() }
        pastEventsVC.pastEvents = self.pastEvents

        upcomingEvents = events.filter { $0.eventDate! > Date() }
        upcomingEventsVC.upcomingEvents = self.upcomingEvents

        allEvents = []
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
            destinationVC.currentHost = self.currentHost
            destinationVC.eventController = self.eventController
            destinationVC.hostController = self.hostController
        } else if segue.identifier == "PastEventsSegue" {
            guard let destinationVC = segue.destination as? PastEventsViewController else { return }
            self.pastEventsVC = destinationVC
            destinationVC.currentHost = self.currentHost
            destinationVC.eventController = self.eventController
            destinationVC.hostController = self.hostController
        } else if segue.identifier == "HostingEventsSegue" {
            guard let destinationVC = segue.destination as? HostingEventsViewController else { return }
            self.hostingEventsVC = destinationVC
            destinationVC.currentHost = self.currentHost
            destinationVC.eventController = self.eventController
            destinationVC.hostController = self.hostController
        }
    }
}
