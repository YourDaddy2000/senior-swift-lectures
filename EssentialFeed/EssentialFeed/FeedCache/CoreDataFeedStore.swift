//
//  CoreDataFeedStore.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 08.11.2021.
//

import Foundation

public final class CoreDataFeedStore: FeedStoreProtocol {
    public init() {}
    
    public func retrieve(completion: @escaping RetrievalCompletion) {
        completion(.empty)
    }
    
    public func insert(_ feed: [LocalFeedImage], timestamp: Date, completion: @escaping InsertionCompletion) {
        
    }
    
    public func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        
    }
}
