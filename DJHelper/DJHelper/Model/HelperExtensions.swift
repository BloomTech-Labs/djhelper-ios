//
//  HelperExtensions.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/2/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

// MARK: - Date Ext.
extension Date {
    func stringFromDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy h:mm a"
        return formatter.string(from: self)
    }
}

// MARK: - String Ext.
extension String {
    func dateFromString() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "M/d/yyyy h:mm a"
        return formatter.date(from: self)
    }
}

// MARK: - UIView Ext.
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

// MARK: - UIViewController Ext.

extension UIViewController {
    func alertController(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alert.addAction(okAction)
        present(alert, animated: true)
    }

    func activityIndicator(shouldStart: Bool) {
        let activityIndicator = UIActivityIndicatorView(style: .large)
        shouldStart == true ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
}
