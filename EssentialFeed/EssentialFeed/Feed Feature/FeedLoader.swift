//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 13.08.2021.
//

import Foundation

public typealias LoadFeedResult = Swift.Result<[FeedImage], Error>

public protocol FeedLoader {
    func load(completion: @escaping (LoadFeedResult) -> Void)
}
