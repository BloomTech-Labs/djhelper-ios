//
//  CustomAlert.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/11/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

// In several places, we used this custom alert instead of the standard UIAlertController.
// To be consistent we probably should have used this throughout.
// It is fairly plain now, but the design can be modified to your preference.
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
        titleLabel.textColor = .black

        alertView.addSubview(titleLabel)

        //CONFIGURE BUTTON
        let button = UIButton(frame: CGRect(x: 0, y: alertView.frame.size.height - 50, width: alertView.frame.size.width, height: 50))

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

        // CONFIGURE MESSAGE LABEL
        let messageLabel = UILabel()

        messageLabel.numberOfLines = 0
        messageLabel.text = message
        messageLabel.font = UIFont(name: "Palatino", size: 18)
        messageLabel.textAlignment = .center
        messageLabel.lineBreakMode = .byWordWrapping
        messageLabel.textColor = .black

        alertView.addSubview(messageLabel)

        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate(
            [messageLabel.leadingAnchor.constraint(equalTo: alertView.leadingAnchor),
             messageLabel.trailingAnchor.constraint(equalTo: alertView.trailingAnchor),
             messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: -60),
             messageLabel.bottomAnchor.constraint(equalTo: button.topAnchor, constant: 50)]
        )
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
                UIView.animate(withDuration: 0.25,
                               animations: {
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
