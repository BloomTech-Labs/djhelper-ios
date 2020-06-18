//
//  HostEventsTableViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 6/1/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit
import CoreData

class HostEventsTableViewController: UIViewController {

    var eventController: EventController!
    var hostController: HostController!
    var currentHost: Host!
    var isGuest: Bool?
    var hostEventCount: Int?

    @IBOutlet var tableView: UITableView!

    // MARK: - NSFETCHEDRESULTSCONTROLLER CONFIGURATION
    lazy var fetchedResultsController: NSFetchedResultsController<Event> = {
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        let dateSortDescriptor = NSSortDescriptor(key: "eventDate", ascending: true)
        fetchRequest.sortDescriptors = [dateSortDescriptor]

        if self.currentHost != nil {
            let fetchRequestPredicate = NSPredicate(format: "host.identifier == %i", self.currentHost!.identifier)
            fetchRequest.predicate = fetchRequestPredicate
        }

        let nsfrc = NSFetchedResultsController(fetchRequest: fetchRequest,
                    managedObjectContext: CoreDataStack.shared.mainContext,
                    sectionNameKeyPath: "eventDate",
                    cacheName: nil)

        do {
            nsfrc.delegate = self
            try nsfrc.performFetch()
            print("performed nsfrc fetch on Event")
        } catch {
            print("""
                Error on line: \(#line) in function: \(#function)\n
                Readable error: \(error.localizedDescription)\n Technical error: \(error)
                """)
        }

        return nsfrc
    }()

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        let barViewControllers = self.tabBarController?.viewControllers
        guard let profileVC = barViewControllers?[1] as? HostProfileViewController else { return }
        profileVC.currentHost = self.currentHost
        profileVC.hostController = self.hostController
        guard let newEventNC = barViewControllers?[2] as? UINavigationController else { return }
        if let newEventVC = newEventNC.viewControllers.first as? NewEventViewController {
            newEventVC.eventController = self.eventController
            newEventVC.hostController = self.hostController
            newEventVC.currentHost = self.currentHost
            newEventVC.hostEventCount = self.hostEventCount
        }
        eventController.fetchAllEventsFromServer(for: self.currentHost) { (results) in
            switch results {
            case .success:
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            case .failure:
                return
            }
        }
    }

     // MARK: - Navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "createEventSegue":
            if let newEventVC = segue.destination as? CreateEventViewController {
                newEventVC.hostController = hostController
                newEventVC.currentHost = currentHost
                newEventVC.eventController = eventController
            }
        case "showEventSegue":
            guard let newEventVC = segue.destination as? EventPageViewController, let index = tableView.indexPathForSelectedRow else {
                print("Error on line: \(#line) in function: \(#function)\n")
                return
                    }

            let event = fetchedResultsController.object(at: index)
            newEventVC.event = event
            newEventVC.hostController = hostController
            newEventVC.currentHost = currentHost
            newEventVC.eventController = eventController
        default:
            return
        }
     }
}

// MARK: - TableView Data Source
extension HostEventsTableViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.hostEventCount = fetchedResultsController.sections?[section].numberOfObjects
        return self.hostEventCount ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "EventCell", for: indexPath)
        let event = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = event.name
        cell.detailTextLabel?.text = event.eventDate?.stringFromDate()

        return cell
    }

    // Swipe to delete
    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let event = fetchedResultsController.object(at: indexPath)
            eventController.deleteEvent(for: event)
        }
    }
}

// MARK: - FRC Delegate
extension HostEventsTableViewController: NSFetchedResultsControllerDelegate {
    //will tell the tableViewController get ready to do something.
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            //there was a new entry so now we need to make a new cell.
            guard let newIndexPath = newIndexPath else {return}
            tableView.insertRows(at: [newIndexPath], with: .automatic)
        case .delete:
            guard let indexPath = indexPath else {return}
            tableView.deleteRows(at: [indexPath], with: .fade)
        case .move:
            guard let indexPath = indexPath, let newIndexpath = newIndexPath else {return}
            tableView.moveRow(at: indexPath, to: newIndexpath)
        case .update:
            guard let indexPath = indexPath else {return}
            tableView.reloadRows(at: [indexPath], with: .automatic)
        @unknown default:
            fatalError()
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            let indexSet = IndexSet(integer: sectionIndex)
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            let indexSSet = IndexSet(integer: sectionIndex)
            tableView.deleteSections(indexSSet, with: .automatic)
        default:
            break
        }
    }
}
