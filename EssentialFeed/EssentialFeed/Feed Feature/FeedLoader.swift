//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 13.08.2021.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
