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

        // create fetchRequest to look for a Host object with this username from CoreData.
        // if username is found, set the currentHost variable to the Host fetched from the fetchRequest.
        // if not found, present an alert and prompt to the registration scene.
        let fetchRequest: NSFetchRequest<Host> = Host.fetchRequest()
        let predicate = NSPredicate(format: "username == %@", username)
        fetchRequest.predicate = predicate
        var fetchedHosts: [Host]?

        let moc = CoreDataStack.shared.mainContext
        moc.performAndWait {
            fetchedHosts = try? fetchRequest.execute()
        }
        if let host = fetchedHosts?.first {

            self.currentHost = host
        // call hostLogIn network function
        // handle possible error
        // transition to primary view controller
        hostController.logIn(with: host) { (result) in
            switch result {
            case .success:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "SignInSegue", sender: self)
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
        } else {
            let alertController = UIAlertController(title: "Username Not Found",
                                                    message: """
                The username \(username) was not found on this device. Please verify and try again, or tap Register to create a new account.
                """,
                preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(alertAction)
            self.present(alertController, animated: true)
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
                    if let logInVC = logInNC.viewControllers.first as? HostEventsTableViewController {
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
