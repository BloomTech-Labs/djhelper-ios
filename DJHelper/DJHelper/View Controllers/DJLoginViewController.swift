//
//  DJLoginViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 5/28/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class DJLoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: - Properties
    var hostController = HostController()
    var currentHost: Host?
    
    // MARK: - Outlets
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.layer.cornerRadius = 25
        
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
        
        // call hostLogIn network function
        // handle possible error
        // transition to primary view controller
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DJRegisterSegue" {
            if let djRegisterVC = segue.destination as? DJRegisterViewController {
                djRegisterVC.hostController = hostController
            }
        }
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
