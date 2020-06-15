//
//  CustomAlert.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/11/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class CustomAlert {
    
    struct Constants {
        static let backgroundAlphaTo: CGFloat = 0.6
    }

    private let alertView: UIView = {
        let alert = UIView()
        alert.backgroundColor = .white
        alert.layer.masksToBounds = true
        alert.layer.cornerRadius = 12
        return alert
    }()

    private let backgroundView: UIView = {
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        backgroundView.alpha = 0.0
        return backgroundView
    }()

    private var myTargetView: UIView?

     func showAlert(with title: String,
                    message: String,
                    on viewController: UIViewController) {
        guard let targetView = viewController.view  else { return }
        myTargetView = targetView

        backgroundView.frame = targetView.bounds
        targetView.addSubview(backgroundView)

        //CONFIGURE ALERT VIEW
        alertView.frame = CGRect(x: 40, y: -300, width: targetView.frame.size.width - 80, height: 300)
        targetView.addSubview(alertView)

        // CONFIGURE TITLE LABEL
        let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: alertView.frame.size.width, height: 80))

        titleLabel.text = title
        titleLabel.textAlignment = .center

        alertView.addSubview(titleLabel)

        // CONFIGURE MESSAGE LABEL
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 80, width: alertView.frame.size.width, height: 170))

        messageLabel.numberOfLines = 0
        messageLabel.text = message
        messageLabel.textAlignment = .left

        alertView.addSubview(messageLabel)

        //CONFIGURE BUTTON
        let button = UIButton(frame: CGRect(x: 0, y: alertView.frame.size.height - 50 , width: alertView.frame.size.width, height: 50))

        button.setTitle("Dismiss", for: .normal)
        button.setTitleColor(.blue, for: .normal)
        button.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
        alertView.addSubview(button)

        //dull out background view
        UIView.animate(withDuration: 0.25, animations: {
            self.backgroundView.alpha = Constants.backgroundAlphaTo

        }, completion: { done in
            if done {
                //another animation in the original animation closure
                UIView.animate(withDuration: 0.25, animations: {
                    self.alertView.center = targetView.center
                })
            }
        })
    }

    @objc func dismissAlert() {
        guard let targetView = myTargetView else {
            print("Error on line: \(#line) in function: \(#function)\n")
            return
        }

        UIView.animate(withDuration: 0.25, animations: {

            self.alertView.frame = CGRect(x: 40, y: targetView.frame.size.height, width: targetView.frame.size.width - 80, height: 300)

        }, completion: { done in
            if done {
                //another animation in the original animation closure
                UIView.animate(withDuration: 0.25, animations:  {
                    self.backgroundView.alpha = 0
                }, completion: { finished in
                    if finished {
                        self.alertView.removeFromSuperview()
                        self.backgroundView.removeFromSuperview()
                    }
                })
            }
        })
    }
}
