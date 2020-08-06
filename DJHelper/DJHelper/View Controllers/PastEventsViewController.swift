//
//  PastEventsViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 8/5/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class PastEventsViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var pastEvents: [Event]? {
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
        return pastEvents?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let pastEvents = pastEvents,
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "eventCell", for: indexPath) as? HostEventCollectionViewCell else { return UICollectionViewCell() }

        let event = pastEvents[indexPath.item]
        cell.event = event

        return cell
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
