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
    var currentHost: Host?
    var eventController: EventController?
    let todaysDate = Date().stringFromDate()
    var eventsHappeningNow: [Event]!
    var upcomingEvents: [Event]!
    var pastEvents: [Event]!

    @IBOutlet weak var upcomingShowsCollectionView: UICollectionView!
    @IBOutlet weak var hostingEventCollectionView: UICollectionView!
    @IBOutlet weak var pastEventsCollectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
        setDataSourceForCollectionViews()
        sortEvents(events: fetchRequest())
    }

    private func setDataSourceForCollectionViews() {
        upcomingShowsCollectionView.dataSource = self
        hostingEventCollectionView.dataSource = self
        pastEventsCollectionView.dataSource = self
    }

    private func fetchEventsCurrentHostCreated() {
        guard let passedInHost = currentHost, let eventController = eventController else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return
        }
    }
    
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
        return events ?? []
    }

    private func sortEvents(events: [Event]) {
        eventsHappeningNow = events.filter { $0.eventDate == Date() }

        pastEvents = events.filter { $0.eventDate! < Date() }

        upcomingEvents = events.filter { $0.eventDate! > Date() }
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
        return 40
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: UICollectionViewCell?

        return cell!
    }
}
