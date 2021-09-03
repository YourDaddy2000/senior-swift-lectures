//
//  RemoteFeedLoader.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 21.08.2021.
//

public final class RemoteFeedLoader: FeedLoader {
    private let url: URL
    private let client: HTTPClient
    
    public enum Error: Swift.Error {
        case connectivityError
        case invalidData
    }
    
    public typealias Result = LoadFeedResult
    
    public init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    public func load(completion: @escaping (Result) -> Void) {
        client.get(from: url) { [weak self] result in
            guard let _ = self else { return }
            switch result {
            case .success(let data, let response):
                completion(FeedItemMapper.map(data, response: response))
            case .failure:sdfsd
                completion(.failure(Error.connectivityError))
            }
        }
    }
}
