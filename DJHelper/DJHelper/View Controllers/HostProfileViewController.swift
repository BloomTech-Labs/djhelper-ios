//
//  HostProfileViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 6/8/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class HostProfileViewController: UIViewController {

    var currentHost: Host? {
        didSet {
            updateViews()
        }
    }
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

        updateViews()
        // Do any additional setup after loading the view.
    }

    @IBAction func saveChanges(_ sender: UIBarButtonItem) {

        guard let host = currentHost,
         let hostController = hostController else { return }

        host.username = usernameTextField.text
        host.name = nameTextField.text
        host.email = emailTextField.text
        host.phone = phoneTextField.text
        if let websiteURLString = websiteTextField.text {
            host.website = URL(string: websiteURLString)
        }
        if let profilePicURLString = profilePicTextField.text {
            host.profilePic = URL(string: profilePicURLString)
        }
        host.bio = bioTextView.text

        // call hostController.updateHost
        // successful result should present alert controller
        // failed result should also present alert controller
    }

    private func updateViews() {
        guard let host = currentHost else { return }
        guard isViewLoaded else { return }

        usernameTextField.text = host.username
        nameTextField.text = host.name
        emailTextField.text = host.email
        phoneTextField.text = host.phone
        websiteTextField.text = host.website?.absoluteString
        profilePicTextField.text = host.profilePic?.absoluteString
        bioTextView.text = host.bio
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
