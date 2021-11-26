//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 13.08.2021.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(completion: @escaping (Result) -> Void)
}
