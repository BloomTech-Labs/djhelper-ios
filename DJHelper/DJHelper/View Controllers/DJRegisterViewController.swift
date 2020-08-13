//
//  DJRegisterViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 5/29/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit
import CoreData

class DJRegisterViewController: ShiftableViewController {

    // MARK: - Properties
    var hostController: HostController!
    var eventController: EventController?
    var currentHost: Host?
    var isGuest: Bool?

    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupButtons()
        setUpSubviews()
        usernameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self

        let tapToDismiss = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapToDismiss)
    }

    func setupButtons() {
        createAccountButton.colorTheme()
        usernameTextField.textContentType = .username
        usernameTextField.textColor = UIColor(named: "customTextColor")
        emailTextField.textContentType = .emailAddress
        emailTextField.keyboardType = .emailAddress
        emailTextField.textColor = UIColor(named: "customTextColor")
        passwordTextField.textColor = UIColor(named: "customTextColor")
        passwordTextField.textContentType = .password
        passwordTextField.isSecureTextEntry = true
        confirmTextField.textContentType = .password
        confirmTextField.isSecureTextEntry = true
    }

    // Programmatically setting up the Sign In button in the view.
    func setUpSubviews() {
        let backToSignIn = UIButton(type: .system)
        backToSignIn.translatesAutoresizingMaskIntoConstraints = false
        backToSignIn.setTitle("Sign In", for: .normal)
        backToSignIn.addTarget(self, action: #selector(self.backToSignIn), for: .touchUpInside)

        let customButtonTitle = NSMutableAttributedString(string: "Sign In", attributes: [
            NSAttributedString.Key.font: UIFont(name: "Helvetica Neue", size: 18)!,
            NSAttributedString.Key.foregroundColor: UIColor(named: "customTextColor")!
        ])

        backToSignIn.setAttributedTitle(customButtonTitle, for: .normal)

        view.addSubview(backToSignIn)

        backToSignIn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40).isActive = true
        backToSignIn.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 40).isActive = true
    }

    @objc private func backToSignIn() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Actions
    @IBAction func hostRegister(_ sender: UIButton) {
        // check to see that username, email, password, and confirm are not empty
        guard let username = usernameTextField.text,
            !username.isEmpty,
            let email = emailTextField.text,
            !email.isEmpty,
            let password = passwordTextField.text,
            !password.isEmpty,
            let confirmationPassword = confirmTextField.text,
            !confirmationPassword.isEmpty else { return }

        // check to see if password fields are the same
        guard password == confirmationPassword else {

            // present alert if they are not the same
            DispatchQueue.main.async {
                let alertController = UIAlertController(title: "Password Error",
                    message: "Your password and your confirmation password do not match. Please verify and try again.",
                    preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true)
            }
            return
        }

        // create new host object (temp ID until the actual one is returned from server)
        currentHost = Host(username: username, email: email, password: password, identifier: Int32(999))

        // call network register method
        // handle possible error
        // if success, present success alert and transition to sign in VC
        guard let host = self.currentHost else { return }
        hostController.registerHost(with: host) { (result) in
            switch result {
            case let .success(newHost):

                self.currentHost?.identifier = newHost.identifier

                try? CoreDataStack.shared.save()

                // if registration is successful, present alert with "login" button and "cancel" button
                // if login is successful, transition to hostEventsTableViewController
                // if unsuccessful, present alert with failure notice and return to screen

                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Successful Registration",
                        message: "Congratulations! Your account has been created. Tap Sign In to continue to your Events list, or cancel to return.",
                            preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "Sign In", style: .default) { (_) in
                        guard let hostLogin = self.currentHost?.hostLogin else { return }
                        self.hostController.logIn(with: hostLogin) { (result) in
                            switch result {
                            case .success:
                                DispatchQueue.main.async {
                                    self.performSegue(withIdentifier: "LogInSegue", sender: self)
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
                    alertController.addAction(alertAction)
                    alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alertController, animated: true)
                }

            case let .failure(error):
                DispatchQueue.main.async {
                    let alertController = UIAlertController(title: "Registration Error",
                        message: "There was an error registering with message: \(error). Please verify and try again.",
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
        if segue.identifier == "LogInSegue" {
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
        }
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
