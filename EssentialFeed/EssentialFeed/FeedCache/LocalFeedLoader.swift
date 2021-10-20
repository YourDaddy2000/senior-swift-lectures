//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 11.10.2021.
//

private final class FeedCachePolicy {
    let calendar = Calendar(identifier: .gregorian)
    let currentDate: () -> Date
    
    init(currentDate: @escaping () -> Date) {
        self.currentDate = currentDate
    }
    
    
    var maxCacheAgeInDays: Int { 7 }
    
    func validate(_ timestamp: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCacheAgeInDays, to: timestamp) else {
            return false
        }
        return currentDate() < maxCacheAge
    }
}

public final class LocalFeedLoader: FeedLoader {
    private let store: FeedStoreProtocol
    private let currentDate: () -> Date
    private let cachePolicy: FeedCachePolicy
    
    public init(store: FeedStoreProtocol, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
        self.cachePolicy = FeedCachePolicy(currentDate: Date.init)
    }
}

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    }
}

private extension Array where Element == LocalFeedImage {
    func toModels() -> [FeedImage] {
        return map { FeedImage(id: $0.id, description: $0.description, location: $0.location, url: $0.url) }
    }
}

extension LocalFeedLoader {
    public typealias SaveResult = Error?
    
    public func save(_ feed: [FeedImage], completion: @escaping (SaveResult) -> Void = { _ in } ) {
        store.deleteCachedFeed() { [weak self] error in
            guard let self = self else { return }
            if let cacheDeletionError = error {
                completion(cacheDeletionError)
            } else {
                self.cache(feed, with: completion)
            }
        }
    }
    
    private func cache(_ feed: [FeedImage], with completion: @escaping (SaveResult) -> Void) {
        store.insert(feed.toLocal(), timestamp: currentDate()) { [weak self] error in
            guard let _ = self else { return }
            completion(error)
        }
    }
}

extension LocalFeedLoader {
    public typealias LoadResult = LoadFeedResult
    
    public func load(completion: @escaping (LoadResult) -> Void) {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                completion(.failure(error))
                
            case let .found(feed, timestamp) where self.cachePolicy.validate(timestamp) :
                completion(.success(feed.toModels()))
            
            case .found, .empty:
                completion(.success([]))
            }
        }
    }
}

extension LocalFeedLoader {
    public func validateCache() {
        store.retrieve { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure:
                self.store.deleteCachedFeed { _ in }
                
            case let .found(_, timestamp) where !self.cachePolicy.validate(timestamp):
                self.store.deleteCachedFeed { _ in }
            case .empty, .found: break
            }
        }
    }
}
