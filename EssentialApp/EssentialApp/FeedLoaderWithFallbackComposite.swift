//
//  FeedLoaderWithFallbackComposite.swift
//  EssentialApp
//
//  Created by Roman Bozhenko on 15.02.2022.
//

import EssentialFeed

public final class FeedLoaderWithFallbackComposite: FeedLoader {
    private let primary: FeedLoader
    private let fallback: FeedLoader
    
    public init(primary: FeedLoader, fallback: FeedLoader) {
        self.primary = primary
        self.fallback = fallback
    }
    
    public func load(completion: @escaping (FeedLoader.Result) -> Void) {
        primary.load { [weak self] result in
            switch result {
            case .success(let success):
                completion(.success(success))
            case .failure:
                self?.fallback.load(completion: completion)
            }
        }
    }
}
