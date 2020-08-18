//
//  DJLoginViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 5/28/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit
import CoreData

class DJLoginViewController: ShiftableViewController {

    // MARK: - Properties
    var hostController = HostController()
    var eventController = EventController()
    var currentHost: Host?
    var isGuest: Bool = false

    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var guestButton: UIButton!
    @IBOutlet var registerButton: UIButton!
    @IBOutlet var forgotPasswordButton: UIButton!

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButtons()

        let tapToDismiss = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapToDismiss)

        updateViews()
    }

    // MARK: - Actions
    @IBAction func hostLogIn(_ sender: UIButton) {
        guard let username = usernameTextField.text,
            !username.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty else { return }

        let hostLogin: HostLogin = HostLogin(username: username, password: password)

            // call hostLogIn network function
            // handle possible error
            // transition to primary view controller
            hostController.logIn(with: hostLogin) { (result) in
                switch result {
                case let .success(hostResponse):
                    let fetchRequest: NSFetchRequest<Host> = Host.fetchRequest()
                    let predicate = NSPredicate(format: "username = %@", hostResponse.username)
                    fetchRequest.predicate = predicate
                    var fetchedHosts: [Host]?

                    let moc = CoreDataStack.shared.mainContext
                    moc.performAndWait {
                        fetchedHosts = try? fetchRequest.execute()
                    }
                    if let host = fetchedHosts?.first {
                        self.currentHost = host
                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "SignInSegue", sender: self)
                        }
                    } else {
                        let newHost = Host(name: hostResponse.name, username: hostResponse.username, email: hostResponse.email, password: password, bio: hostResponse.bio, identifier: hostResponse.identifier, phone: hostResponse.phone, profilePic: hostResponse.profilePic, website: hostResponse.website, context: CoreDataStack.shared.mainContext)

                        self.currentHost = newHost
                        try? CoreDataStack.shared.save()

                        DispatchQueue.main.async {
                            self.performSegue(withIdentifier: "SignInSegue", sender: self)
                        }

                    }
                case let .failure(error):
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "LogIn Error",
                                                                message: "There was an error signing in with message: \(error). Please verify and try again.",
                            preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alertController.addAction(alertAction)
                        self.present(alertController, animated: true)
                    }
                    return
                }
            }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "djRegisterSegue":
            if let djRegisterVC = segue.destination as? DJRegisterViewController {
                djRegisterVC.hostController = hostController
                djRegisterVC.eventController = eventController
                djRegisterVC.isGuest = isGuest
            }
        case "SignInSegue":
            if let barViewControllers = segue.destination as? UITabBarController {

                if let logInNC = barViewControllers.viewControllers![0] as? UINavigationController {
                    if let logInVC = logInNC.viewControllers.first as? HostEventViewController {
                        logInVC.modalPresentationStyle = .fullScreen
                        logInNC.navigationBar.isHidden = true
                        logInVC.currentHost = currentHost
                        logInVC.hostController = hostController
                        logInVC.eventController = eventController
                        logInVC.isGuest = isGuest
                    }
                }
            }
        case "GuestSignInSegue":
            if let guestSignInVC = segue.destination as? GuestLoginViewController {
                guestSignInVC.eventController = eventController
                guestSignInVC.hostController = hostController
            }
        default:
            return
        }
    }

    func setupButtons() {
        signInButton.colorTheme()
        guestButton.colorTheme()

        let registerButtonTitle = NSMutableAttributedString(string: "Register", attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 18)!,
            NSAttributedString.Key.foregroundColor: UIColor(named: "customTextColor")!
        ])
        registerButton.setAttributedTitle(registerButtonTitle, for: .normal)

        let forgotPasswordButtonTitle = NSMutableAttributedString(string: "Forgot Password", attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 18)!,
            NSAttributedString.Key.foregroundColor: UIColor(named: "customTextColor")!
        ])
        forgotPasswordButton.setAttributedTitle(forgotPasswordButtonTitle, for: .normal)
    }

    func updateViews() {
        guard isViewLoaded else { return }
        guard let host = currentHost else { return }

        usernameTextField.text = host.username
        passwordTextField.text = host.password
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}
