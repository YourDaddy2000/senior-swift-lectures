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
        guard isOK(response),
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
                  throw RemoteImageCommentsLoader.Error.invalidData
        }
        
        return root.items
    }
    
    private static func isOK(_ response: HTTPURLResponse) -> Bool {
        (200...299).contains(response.statusCode)
    }
}
