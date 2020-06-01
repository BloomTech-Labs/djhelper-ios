//
//  EventController.swift
//  DJHelper
//
//  Created by Michael Flowers on 6/1/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation
class EventController {
    private let baseURL = URL(string: "https://api.dj-helper.com/api/auth/event/")
    let dataLoader: NetworkDataLoader
    
    init(dataLoader: NetworkDataLoader = URLSession.shared){
        self.dataLoader = dataLoader
    }
    
    //MARK: - AUTHORIZE AN EVENT
    ///The server returns an object with the event data
    func authorize(event: Event, completion: @escaping (EventRepresentation, Error) -> Void){
        
    }
}
