//
//  FeedImageDataCache.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 20.02.2022.
//

import Foundation

public protocol FeedImageDataCache {
    typealias Result = Swift.Result<Void, Error>
    
    func save(_ data: Data, for url: URL, completion: @escaping (FeedImageDataCache.Result) -> Void )
}
