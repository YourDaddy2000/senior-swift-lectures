//
//  LocalFeedImage.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 12.10.2021.
//

public struct LocalFeedImage: Equatable {
    let id: UUID
    let description: String?
    let location: String?
    let url: URL
    
    public init(url: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = url
        self.description = description
        self.location = location
        self.url = imageURL
    }
}
