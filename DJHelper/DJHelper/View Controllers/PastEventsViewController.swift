//
//  PastEventsViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 8/5/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

// Takes the pastEvents array passed from HostEventViewController and populates the collection view.

class PastEventsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var currentHost: Host?
    var eventController: EventController?
    var hostController: HostController?
    var pastEvents: [Event]? {
        didSet {
            self.collectionView.reloadData()
        }
    }

    @IBOutlet var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pastEvents?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let pastEvents = pastEvents,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as? HostEventCollectionViewCell else {
                return UICollectionViewCell()
        }

        let event = pastEvents[indexPath.item]
        cell.event = event

        return cell
    }

    // If a cell is tapped, it instantiates a new eventDetailVC with the event details.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let eventDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "EventDetailVC") as? EventPlaylistViewController,
            let pastEvents = pastEvents else { return }
        eventDetailVC.event = pastEvents[indexPath.item]
        eventDetailVC.modalPresentationStyle = .fullScreen
        eventDetailVC.currentHost = currentHost
        eventDetailVC.hostController = hostController
        eventDetailVC.eventController = eventController
        eventDetailVC.isGuest = false
        self.navigationController?.pushViewController(eventDetailVC, animated: true)
    }
}
