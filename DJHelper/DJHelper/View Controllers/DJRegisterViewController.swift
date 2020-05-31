//
//  DJRegisterViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 5/29/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class DJRegisterViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Properties
    var hostController: HostController!
    var currentHost: Host?

    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        createAccountButton.layer.cornerRadius = 25

        let tapToDismiss = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapToDismiss)
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
                let alertController = UIAlertController(title: "Password Error", message: "Your password and your confirmation password do not match. Please verify and try again.", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(alertAction)
                self.present(alertController, animated: true)
            }
            return
        }

        // create new host object -- I need to convenience initializer to do this

        // call network register method
        // handle possible error
        // if success, present success alert and transition to sign in VC
        guard let host = self.currentHost else { return }
        hostController.registerHost(with: host) { (result) in
            switch result {
            case .success(_):
                <#code#>
            case .failure(_):
                <#code#>
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "LogInSegue" {
            if let logInVC = segue.destination as? DJLoginViewController {
                logInVC.currentHost = currentHost
                logInVC.hostController = hostController
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}
