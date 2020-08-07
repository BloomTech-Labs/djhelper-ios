//
//  UpcomingEventsViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 8/5/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class UpcomingEventsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var currentHost: Host?
    var eventController: EventController?
    var hostController: HostController?
    var upcomingEvents: [Event]? {
        didSet {
            self.collectionView.reloadData()
        }
    }

    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return upcomingEvents?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let upcomingEvents = upcomingEvents,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as? HostEventCollectionViewCell else { return UICollectionViewCell() }

        let event = upcomingEvents[indexPath.item]
        cell.event = event

        return cell
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "upcomingEventsDetailSegue" {
            guard let eventDetailVC = segue.destination as? EventPlaylistViewController else { return }

            guard let cell = sender as? UICollectionViewCell,
                let indexPath = self.collectionView.indexPath(for: cell),
                let upcomingEvents = upcomingEvents else { return }
            eventDetailVC.event = upcomingEvents[indexPath.item]
            eventDetailVC.modalPresentationStyle = .fullScreen
            eventDetailVC.currentHost = currentHost
            eventDetailVC.hostController = hostController
            eventDetailVC.eventController = eventController
            eventDetailVC.isGuest = false
        }
    }
}
