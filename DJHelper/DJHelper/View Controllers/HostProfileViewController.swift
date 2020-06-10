//
//  HostProfileViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 6/8/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class HostProfileViewController: UIViewController {

    var currentHost: Host?
    var hostController: HostController?

    @IBOutlet var usernameTextField: UITextField!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var phoneTextField: UITextField!
    @IBOutlet var websiteTextField: UITextField!
    @IBOutlet var profilePicTextField: UITextField!
    @IBOutlet var bioTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func saveChanges(_ sender: UIBarButtonItem) {
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
