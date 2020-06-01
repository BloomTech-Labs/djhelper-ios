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
        let host = Host(name: "test18 ", username: "test18", email: "test18", password: "test18", bio: "test18", identifier: 1, phone: "test18", profilePic: URL(string: "test18")!, website: URL(string: "test18")!)
        //        hc.registerHost(with: host) { (result) in
        //            switch result {
        //            case .success(let host): print("successful host: \(String(describing: host.name))")
        //            case .failure(let error): print("Error on line: \(#line) in function: \(#function)\n Readable error: \(error.localizedDescription)\n Technical error: \(error)")
        //            }
        //        }
        hc.logIn(with: host) { (result) in
            switch result {
            case .success(let host): print("successful host: \(String(describing: host.name))")
            case .failure(let error): print("Error on line: \(#line) in function: \(#function)\n Readable error: \(error.localizedDescription)\n Technical error: \(error)")
            }
        }
    }
}
