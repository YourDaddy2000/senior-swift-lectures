//
//  LocalFeedLoader.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 11.10.2021.
//

public final class LocalFeedLoader {
    private let store: FeedStoreProtocol
    private let currentDate: () -> Date
    
    public typealias SaveResult = Error?
    
    public init(store: FeedStoreProtocol, currentDate: @escaping () -> Date) {
        self.store = store
        self.currentDate = currentDate
    }
    
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

private extension Array where Element == FeedImage {
    func toLocal() -> [LocalFeedImage] {
        return map { LocalFeedImage(url: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
    }
}
