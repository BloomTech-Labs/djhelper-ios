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

    // My plan is to do a fetch request to see if the Host identifier exists in core data.
    // If it does not exist, we will create a host object and add it to core data.
    // We will then create a fetched results controller to get the results for the table view data source.

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("current host username: \(currentHost?.username)")
        print("token: \(hostController?.bearer?.token)")

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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1 // TODO: update code
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell() // TODO: update code
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
