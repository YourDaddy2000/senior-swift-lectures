//
//  FeedImageDataStore.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 30.01.2022.
//

protocol FeedImageDataStore {
    typealias Result = Swift.Result<Data?, Error>
    
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
    
    enum Error: Swift.Error {
        case failed
        case notFound
    }
    
    init(store: FeedImageDataStore) {
        self.store = store
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
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
}
