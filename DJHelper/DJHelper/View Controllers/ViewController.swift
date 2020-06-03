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
        
//        let hc = HostController()
//        let host = Host(name: "test20 ", username: "test20",
//                        email: "test20", password: "test20", bio: "test20",
//                        identifier: 1, phone: "test20", profilePic: URL(string: "test20")!,
//                        website: URL(string: "test20")!)
//                hc.registerHost(with: host) { (result) in
//                    switch result {
//                    case .success(let host): print("successful host: \(String(describing: host.name))")
//                    case .failure(let error): print("Error on line: \(#line) in function: \(#function)\n Readable error: \(error.localizedDescription)\n Technical error: \(error)")
//                    }
//                }
//        hc.logIn(with: host) { (result) in
//            switch result {
//            case .success(let host): print("successful host: \(String(describing: host.name))")
//            case .failure(let error): print("Error on line: \(#line) in function: \(#function)\n Readable error: \(error.localizedDescription)\n Technical error: \(error)")
//            }
//        }
        let ec = EventController()
        let date = Date()

        let event = Event(name: "e5", eventType: "e5",
                          eventDescription:"e5" , eventDate: date,
                          hostID: 1, locationID: 1, startTime: date,
                          endTime: Date(), imageURL: URL(string: "e5")!,
                          notes: "e5", eventID: 1)

        ec.authorize(event: event) { (results) in
            switch results {
            case .success(let er): print("this is the event name: \(er.name)")
            case .failure(let error): print("Error on line: \(#line) in function: \(#function)\n Readable error: \(error.localizedDescription)\n Technical error: \(error)")
            }
        }
        
        }
    
}
