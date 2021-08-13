//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 13.08.2021.
//

import Foundation

enum LoadFeedResult {
    case success([FeedItem])
    case error(Error)
}

protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
