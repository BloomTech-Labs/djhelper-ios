//
//  HostEventViewController.swift
//  DJHelper
//
//  Created by Michael Flowers on 7/29/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class HostEventViewController: UIViewController {

    @IBOutlet weak var upcomingShowsCollectionView: UICollectionView!
    @IBOutlet weak var hostingEventCollectionView: UICollectionView!
    @IBOutlet weak var pastEventsCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDataSourceForCollectionViews()
    }
    
    private func setDataSourceForCollectionViews() {
        upcomingShowsCollectionView.dataSource = self
        hostingEventCollectionView.dataSource = self
        pastEventsCollectionView.dataSource = self
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
