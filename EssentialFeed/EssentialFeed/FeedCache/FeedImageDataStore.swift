//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 30.01.2022.
//

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    typealias InsertionResult = Swift.Result<Void, Error>
    
    func insert(_ data: Data, for url: URL, completion: @escaping (InsertionResult) -> Void)
    func retrieve(dataForURL url: URL, completion: @escaping (Result) -> Void)
}

final class LocalFeedImageLoader: FeedImageDataLoader {
    private final class Task: FeedImageDataLoaderTask {
        private var completion: ((FeedImageDataLoader.Result) -> Void)?
        
        init(_ completion: @escaping (FeedImageDataLoader.Result) -> Void) {
            self.completion = completion
        }
        
        func complete(with result: FeedImageDataLoader.Result) {
            completion?(result)
        }
        
        func cancel() {
            preventFurtherCompletions()
        }
        
        private func preventFurtherCompletions() {
            completion = nil
        }
    }
    
    private let store: FeedImageDataStore
    
    public enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    public init(store: FeedImageDataStore) {
        self.store = store
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        let task = Task(completion)
        store.retrieve(dataForURL: url) { [weak self] result in
            guard let _ = self else { return }
            task.complete(with: result
                        .mapError { _ in Error.failed }
                        .flatMap { data in
                data.map { .success($0) } ?? .failure(Error.notFound)
            })
        }
        return task
    }
    
    public typealias SaveResult = Result<Void, Swift.Error>
    
    public func save(_ data: Data, for url: URL, completion: (SaveResult) -> Void) {
        store.insert(data, for: url) { _ in
            
        }
    }
}
