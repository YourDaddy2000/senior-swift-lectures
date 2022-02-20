//
//  FeedCache.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 20.02.2022.
//

import Foundation

public protocol FeedCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ feed: [FeedImage], completion: @escaping (FeedCache.Result) -> Void)
}
