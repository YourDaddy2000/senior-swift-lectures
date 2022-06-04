//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 04.06.2022.
//

import Foundation

public enum FeedEndpoint {
    case get

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get:
            return baseURL.appendingPathComponent("/v1/feed")
        }
    }
}
