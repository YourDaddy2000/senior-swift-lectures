//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 21.08.2021.
//

public typealias RemoteFeedLoader = RemoteLoader<[FeedImage]>

public extension RemoteFeedLoader {
    convenience init(url: URL, client: HTTPClient) {
        self.init(url: url, client: client, mapper: FeedItemMapper.map)
    }
}
