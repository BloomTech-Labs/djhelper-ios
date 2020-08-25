//
//  HostingEventsViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 8/5/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

// Takes the hostingEvents array passed from HostEventViewController and populates the collection view.

class HostingEventsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var currentHost: Host?
    var eventController: EventController?
    var hostController: HostController?
    var hostingEvents: [Event]? {
        didSet {
            self.collectionView.reloadData()
        }
    }

    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hostingEvents?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let hostingEvents = hostingEvents,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as? HostEventCollectionViewCell else {
                return UICollectionViewCell()

        }

        let event = hostingEvents[indexPath.item]
        cell.event = event

        return cell
    }

    // If a cell is tapped, it instantiates a new eventDetailVC with the event details.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let eventDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailVC") as? EventPlaylistViewController,
            let hostingEvents = hostingEvents else { return }
        eventDetailVC.event = hostingEvents[indexPath.item]
        eventDetailVC.modalPresentationStyle = .fullScreen
        eventDetailVC.currentHost = currentHost
        eventDetailVC.hostController = hostController
        eventDetailVC.eventController = eventController
        eventDetailVC.isGuest = false
        self.navigationController?.pushViewController(eventDetailVC, animated: true)
    }

}
