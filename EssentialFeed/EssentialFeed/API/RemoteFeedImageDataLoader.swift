//
//  RemoteFeedImageDataLoader.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 23.01.2022.
//

public final class RemoteFeedImageDataLoader: FeedImageDataLoader {
    private let client: HTTPClient
    
    public init(client: HTTPClient) {
        self.client = client
    }
    
    public enum Error: Swift.Error {
        case connectivity
        case invalidData
    }
    
    private final class HTTPTaskWrapper: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        var wrapped: HTTPClientTask?
        
        init(completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
            wrapped?.cancel()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = HTTPTaskWrapper(completion: completion)
        
        task.wrapped = client.get(from: url) { [weak self] result in
            guard let _ = self else { return }
            
            task.complete(with: result
                            .mapError { _ in Error.connectivity }
                            .flatMap { (data, response) in
                let isValidResponse = response.isOK && !data.isEmpty
                return isValidResponse ? .success(data) : .failure(Error.invalidData)
            })
        }
        
        return task
    }
}
