//
//  ImageCommentsMapper.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 17.04.2022.
//

enum ImageCommentsMapper {
    private struct Root: Decodable {
        let items: [RemoteFeedItem]
    }
    
    static func map(_ data: Data, response: HTTPURLResponse) throws -> [RemoteFeedItem] {
        guard response.isOK,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
                  throw RemoteFeedLoader.Error.invalidData
        }
        
        return root.items
    }
}
