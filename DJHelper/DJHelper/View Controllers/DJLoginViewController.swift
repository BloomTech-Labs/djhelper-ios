//
//  DJLoginViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 5/28/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class DJLoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        signInButton.layer.cornerRadius = 25
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
