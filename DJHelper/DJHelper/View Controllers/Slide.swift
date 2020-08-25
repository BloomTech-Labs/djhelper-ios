//
//  Slide.swift
//  DJHelper
//
//  Created by Craig Swanson on 6/18/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

// File for the corresponding Slide.xib
class Slide: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var saveEvent: UIButton!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func layoutSubviews() {
        super .layoutSubviews()
        setupButton()
    }

    private func setupButton() {
        saveEvent.colorTheme()
    }
}
