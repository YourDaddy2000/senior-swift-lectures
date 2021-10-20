//
//  LocalFeedImage.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 12.10.2021.
//

public struct LocalFeedImage: Equatable, Codable {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.url = imageURL
    }
}
