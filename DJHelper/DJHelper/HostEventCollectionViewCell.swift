//
//  HostEventCollectionViewCell.swift
//  DJHelper
//
//  Created by Michael Flowers on 7/30/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class HostEventCollectionViewCell: UICollectionViewCell {
    var event: Event? {
        didSet {
            print("event passed to collection cell")
            updateViews()
        }
    }
    
    @IBOutlet weak var cellView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    
    
    private func updateViews() {
        guard let passedInEvent = event else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return
        }
        
        dateLabel.text = passedInEvent.eventDate?.stringFromDate()
        eventNameLabel.text = passedInEvent.name
        imageView.image = UIImage(named: "up-arrow")!
    }
}
