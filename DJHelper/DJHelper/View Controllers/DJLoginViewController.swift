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
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!

    // MARK: - View Controller Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.layer.cornerRadius = 25
        
        let tapToDismiss = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapToDismiss)
    }
    
    // MARK: - Actions
    @IBAction func hostLogIn(_ sender: UIButton) {
        
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DJRegisterSegue" {
            if let djRegisterVC = segue.destination as? DJRegisterViewController {
                djRegisterVC.hostController = hostController
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }

}
