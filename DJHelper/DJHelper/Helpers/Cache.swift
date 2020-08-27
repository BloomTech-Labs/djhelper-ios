//
//  Cache.swift
//  DJHelper
//
//  Created by Craig Swanson on 8/17/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

// Cache is a class used to store image data in a dictionary
// The network call might be slow so when an image is received, it is put in cache so it doesn't have to reload from the network
// At this point, there is no limit for number of cached objects, but if the number gets large then the cache may need to be replaced after some number of images
class Cache<Key: Hashable, Value> {

    private var cache = [Key: Value]()
    private let queue = DispatchQueue(label: "com.LambdaSchool.DJHelper.CacheQueue")

    /**
     Save a value for a given key. Stores it in memory to avoid further network calls for the same data.

     - Parameter value: The value (data) to stored
     - Parameter key: The key used in the dictionary to associate with the value being stored
     */
    func cache(value: Value, for key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }

    /**
     Return optional data for a given key. The data is stored as a value in a dictionary.

     - Parameter key: The key used in the dictionary to associate with the value being stored
     - Returns: The value (data) associated with the provided key
     */
    func value(for key: Key) -> Value? {
        return queue.sync { cache[key] }
    }
}
