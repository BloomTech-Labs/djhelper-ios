//
//  HostEventCollectionViewCell.swift
//  DJHelper
//
//  Created by Michael Flowers on 7/30/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

// Collection view cell used in the three collection views:
//   - Upcoming Events
//   - Hosting Events
//   - Past Events
// It displays an image associated with event, event date, and event name
class HostEventCollectionViewCell: UICollectionViewCell {
    var event: Event? {
        didSet {
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
        imageView.image = #imageLiteral(resourceName: "musicSymbol")  // the backend does not have resources to store images; we just used a stock image
    }
}
