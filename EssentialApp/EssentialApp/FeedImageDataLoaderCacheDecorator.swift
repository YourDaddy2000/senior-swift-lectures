//
//  FeedImageDataLoaderCacheDecorator.swift
//  EssentialApp
//
//  Created by Roman Bozhenko on 20.02.2022.
//

import Foundation
import EssentialFeed

public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    private let cache: FeedImageDataCache
    
    public init(decoratee: FeedImageDataLoader, cache: FeedImageDataCache) {
        self.decoratee = decoratee
        self.cache = cache
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        return decoratee.loadImageData(from: url) { [weak self] result in
            guard let self = self else { return }
            completion(result.map { imageData in
                self.cache.save(imageData, for: url) { _ in }
                return imageData
            })
        }
    }
}
