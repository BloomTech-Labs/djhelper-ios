//
//  Cache.swift
//  DJHelper
//
//  Created by Craig Swanson on 8/17/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

class Cache<Key: Hashable, Value> {

    func cache(value: Value, for key: Key) {
        queue.async {
            self.cache[key] = value
        }
    }

    func value(for key: Key) -> Value? {
        return queue.sync { cache[key] }
    }

    private var cache = [Key : Value]()
    private let queue = DispatchQueue(label: "com.LambdaSchool.DJHelper.CacheQueue")
}
