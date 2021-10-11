//
//  FeedStoreProtocol.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 11.10.2021.
//

public protocol FeedStoreProtocol {
    typealias DeletionCompletion = (Error?) -> Void
    typealias InsertionCompletion = (Error?) -> Void
    
    func insert(_ items: [FeedItem], timestamp: Date, completion: @escaping InsertionCompletion)
    func deleteCachedFeed(completion: @escaping DeletionCompletion)
}
