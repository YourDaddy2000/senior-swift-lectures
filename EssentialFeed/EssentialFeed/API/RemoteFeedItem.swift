//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 12.10.2021.
//

internal struct RemoteFeedItem: Decodable {
    internal let id: UUID
    internal let description: String?
    internal let location: String?
    internal let image: URL
}
