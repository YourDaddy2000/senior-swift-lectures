//
//  LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Roman Bozhenko on 20.02.2022.
//

import Foundation
import EssentialFeed
import Combine

final class LoaderSpy: FeedImageDataLoader {
//          FeedLoader
    private var feedRequests = [PassthroughSubject<Paginated<FeedImage>, Error>]()
    var loadFeedCounts: Int {
        feedRequests.count
    }
    
    func loadPublisher() -> AnyPublisher<[FeedImage], Error> {
        let publisher = PassthroughSubject<[FeedImage], Error>()
        feedRequests.append(publisher)
        return publisher.eraseToAnyPublisher()
    }
    
    func completeFeedLoading(with feed: Paginated<FeedImage> = [], at index: Int = 0) {
        feedRequests[index].send(feed)
    }
    
    func completeFeedLoadingWithError(at index: Int) {
        let error = NSError(domain: "an error", code: -1)
        feedRequests[index].send(completion: .failure(error))
    }
    
//        FeedImageDataLoader
    private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    
    private(set) var cancelledURLs = [URL]()
    
    var loadedURLs: [URL] {
        messages.map { $0.url }
    }
    
    private struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallBack: () -> Void
        func cancel() {
            cancelCallBack()
        }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        messages.append((url, completion))
        return TaskSpy { [weak self] in self?.cancelledURLs.append(url) }
    }
    
    func complete(with error: NSError, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
}
