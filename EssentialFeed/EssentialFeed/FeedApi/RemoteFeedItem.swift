//
//  RemoteFeedItem.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 12.10.2021.
//

struct RemoteFeedItem: Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let image: URL
}
