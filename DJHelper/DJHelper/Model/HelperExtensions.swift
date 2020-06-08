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
        formatter.dateStyle = .short
        return formatter.date(from: self)
    }
}

extension UIView {
    func shake() {
        let view = self
        let propertyAnimator = UIViewPropertyAnimator(duration: 0.8, dampingRatio: 0.3) {
            view.transform = CGAffineTransform(translationX: 15, y: 0)
        }
        propertyAnimator.addAnimations ({
            view.transform = CGAffineTransform(translationX: 0, y: 0)
        }, delayFactor: 0.4)
        propertyAnimator.startAnimation()
    }
}
