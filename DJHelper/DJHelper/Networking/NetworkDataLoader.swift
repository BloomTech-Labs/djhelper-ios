//
//  NetworkDataLoader.swift
//  DJHelper
//
//  Created by Craig Swanson on 5/20/20.
//  Copyright © 2020 craigswanson. All rights reserved.
//

import Foundation

protocol NetworkDataLoader {
    func loadData(from request: URLRequest, completion: @escaping (Data?, URLResponse?, Error?) -> Void)

    func loadData(from url: URL, completion: @escaping (Data?, Error?) -> Void)
}
