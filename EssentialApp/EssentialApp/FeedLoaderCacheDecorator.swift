//
//  FeedLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Roman Bozhenko on 20.02.2022.
//

import Foundation
import EssentialFeed

public final class FeedLoaderCacheDecorator: FeedLoader {
    let decoratee: FeedLoader
    let cache: FeedCache
    
    public init(decoratee: FeedLoader, cache: FeedCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        decoratee.load { [weak self] result in
            guard let self = self else { return }
            
            completion(result.map({ feed in
                self.cache.save(feed) { _ in }
                
                return feed
            }))
        }
    }
}
