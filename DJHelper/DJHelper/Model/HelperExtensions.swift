//
//  HelperExtensions.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/2/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

extension Date {
    func stringFromDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: self)
    }
}

extension String {
    func dateFromString() -> Date? {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.date(from: self)
    }
}

extension UIView {
    func shake() {
        let view = self
        let propertyAnimator = UIViewPropertyAnimator(duration: 0.4, dampingRatio: 0.2) {
            view.layer.borderColor = UIColor.red.cgColor
            //move it left by 8 pix
            view.transform = CGAffineTransform(translationX: -8, y: 0)
        }
        propertyAnimator.addAnimations({
            //return it back to its original position
            view.transform = CGAffineTransform(translationX: 3, y: 0)
            view.layer.borderColor = UIColor.green.cgColor
        }, delayFactor: 0.4)
        propertyAnimator.startAnimation()
    }
}
