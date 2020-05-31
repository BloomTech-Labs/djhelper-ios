//
//  ViewController.swift
//  DJHelper
//
//  Created by Craig Swanson on 5/20/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let hc = HostController()
        let host = Host(name: "test1", username: "test1", email: "test", password: "test1", bio: "test1", identifier: 1, phone: "test1", profilePic: URL(string: "string")!, website: URL(string: "string")!)
        hc.registerHost(with: host) { (result) in
            switch result {
            case .success(let host): print("successful host: \(String(describing: host.name))")
            case .failure(let error):  print("Error: \(error)")
            }
        }
    }
}
