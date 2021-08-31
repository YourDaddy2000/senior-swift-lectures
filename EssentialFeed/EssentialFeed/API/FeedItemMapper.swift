//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 29.08.2021.
//

enum FeedItemMapper {
    private struct Root: Decodable {
        let items: [Item]
        var feed: [FeedItem] {
            return items.map { $0.feedItem }
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var feedItem: FeedItem {
            FeedItem(
                id: id,
                description: description,
                location: location,
                imageURL: image)
        }
    }
    
    static func map(_ data: Data, response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        
        return .success(root.feed)
    }
}
