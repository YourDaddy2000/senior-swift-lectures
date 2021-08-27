//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 13.08.2021.
//

public struct FeedItem: Equatable, Decodable {
    let id: UUID
    let description: String?
    let location: String?
    let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
    
    enum CodingKeys: String, CodingKey {
        case id,
             description,
             location
        case imageURL = "image"
    }
}
