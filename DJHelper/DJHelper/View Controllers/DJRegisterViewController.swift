//
//  DJRegisterViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 5/29/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class DJRegisterViewController: UIViewController, UITextFieldDelegate {
    
    var hostController: HostController!
    var currentHost: Host?

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createAccountButton.layer.cornerRadius = 25
        
        let tapToDismiss = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapToDismiss)
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
