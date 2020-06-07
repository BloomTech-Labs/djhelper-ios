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

    var hostController: HostController?
    var currentHost: Host?

    @IBOutlet var tableView: UITableView!

    // MARK: - NSFETCHEDRESULTSCONTROLLER CONFIGURATION
    lazy var fetchedResultsController: NSFetchedResultsController<Event> = {
        let fetchRequest: NSFetchRequest<Event> = Event.fetchRequest()
        let dateSortDescriptor = NSSortDescriptor(key: "eventDate", ascending: true)
        fetchRequest.sortDescriptors = [dateSortDescriptor]

        if self.currentHost != nil {
            let fetchRequestPredicate = NSPredicate(format: "host.username == %@", self.currentHost!.username!)
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
    // My plan is to do a fetch request to see if the Host identifier exists in core data.
    // If it does not exist, we will create a host object and add it to core data.
    // We will then create a fetched results controller to get the results for the table view data source.

    /// <#Description#>
    override func viewDidLoad() {
        super.viewDidLoad()

//
//        let host = Host(name: "test20", username: "test20",
//                        email: "test20", password: "test20", bio: "test20",
//                        identifier: 1, phone: "test20", profilePic: URL(string: "test20")!,
//                        website: URL(string: "test20")!)
//

        print("current host username: \(String(describing: currentHost?.username))")
        print("token: \(String(describing: hostController?.bearer?.token))")

        // Do any additional setup after loading the view.
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

extension HostEventsTableViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // TODO: update code
        let cell = tableView.dequeueReusableCell(withIdentifier: "eventCell", for: indexPath)
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
            // TODO: code to delete from core data and the server
        }
    }
}

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
