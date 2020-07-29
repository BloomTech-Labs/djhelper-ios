//
//  SplashScreenViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 7/27/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class SplashScreenViewController: UIViewController {

    var nameLabel: UILabel!
    var appLogo: UIImageView!
    var barOne: LogoView!
    var barTwo: LogoView!
    var barThree: LogoView!
    var barFour: LogoView!
    @IBOutlet var eqStackView: UIStackView!

//    @IBOutlet weak var equalizerView: LogoView!

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(named: "PurpleColor")
        configureLogo()
    }

    func configureLogo() {
        appLogo = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        appLogo.contentMode = .scaleAspectFit
        appLogo.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(appLogo)

        appLogo.image = UIImage(named: "logo")
        appLogo.backgroundColor = .clear

        nameLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 56))
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nameLabel)

        nameLabel.textAlignment = .center
        let labelTitle = NSMutableAttributedString(string: "DJ Helper", attributes: [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 40, weight: .black),
                NSAttributedString.Key.backgroundColor: UIColor.clear,
            NSAttributedString.Key.foregroundColor: UIColor.white
        ])
        nameLabel.attributedText = labelTitle
        nameLabel.minimumScaleFactor = 0.50
        nameLabel.adjustsFontSizeToFitWidth = true

        eqStackView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: 0).isActive = true
        eqStackView.bottomAnchor.constraint(equalTo: appLogo.topAnchor, constant: -10).isActive = true

        NSLayoutConstraint.activate([
            appLogo.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            appLogo.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            appLogo.widthAnchor.constraint(equalTo: appLogo.heightAnchor),
            nameLabel.topAnchor.constraint(equalTo: appLogo.bottomAnchor, constant: 2),
            nameLabel.centerXAnchor.constraint(equalTo: appLogo.centerXAnchor),
            nameLabel.widthAnchor.constraint(equalTo: appLogo.widthAnchor)
        ])
    }
}
