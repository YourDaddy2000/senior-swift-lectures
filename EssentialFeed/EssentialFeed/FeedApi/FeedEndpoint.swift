//
//  FeedEndpoint.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 04.06.2022.
//

import Foundation

public enum FeedEndpoint {
    case get(after: FeedImage? = nil)

    public func url(baseURL: URL) -> URL {
        switch self {
        case .get(let image):
            var components = URLComponents()
            components.scheme = baseURL.scheme
            components.host = baseURL.host
            components.path = baseURL.path + "/v1/feed"
            components.queryItems = [
                .init(name: "limit", value: "10"),
                image.map {
                    URLQueryItem(name: "after_id", value: $0.id.uuidString)
                }
            ].compactMap { $0 }
            return components.url!
        }
    }
}
