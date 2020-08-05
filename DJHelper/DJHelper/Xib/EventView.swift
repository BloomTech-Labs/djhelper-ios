//
//  EventView.swift
//  DJHelper
//
//  Created by Michael Flowers on 7/29/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class EventView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var eventNameLabel: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        colors()
    }
    
    private func colors() {
        print("print colors")
//        dateLabel.backgroundColor = .black
//        eventNameLabel.backgroundColor = .black
    }
}
