//
//  ListViewControllerTests+LoaderSpy.swift
//  EssentialFeediOSTests
//
//  Created by Roman Bozhenko on 17.12.2021.
//

import Foundation
import EssentialFeed
import EssentialFeediOS

class LoaderSpy: FeedImageDataLoader {
//          FeedLoader
    private var feedRequests = [(Swift.Result<[FeedImage], Error>) -> Void]()
    var loadFeedCounts: Int {
        feedRequests.count
    }
    
    func load(completion: @escaping (Swift.Result<[FeedImage], Error>) -> Void) {
        feedRequests.append(completion)
    }
    
    func completeFeedLoading(with feed: [FeedImage] = [], at index: Int = 0) {
        feedRequests[index](.success(feed))
    }
    
    func completeFeedLoadingWithError(at index: Int) {
        let error = NSError(domain: "an error", code: -1)
        feedRequests[index](.failure(error))
    }
    
//        FeedImageDataLoader
    private struct TaskSpy: FeedImageDataLoaderTask {
        let cancelCallBack: () -> Void
        func cancel() {
            cancelCallBack()
        }
    }
    
    private var imageRequests = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    private(set) var canceledImageURLs = [URL]()
    
    var loadedImageURLs: [URL] {
        imageRequests.map { $0.url }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        imageRequests.append((url, completion))
        return TaskSpy { [weak self] in self?.canceledImageURLs.append(url) }
    }
    
    func completeImageLoading(with imageData: Data = Data(), at index: Int = 0) {
        imageRequests[index].completion(.success(imageData))
    }
    
    func completeImageLoadingWithError(at index: Int = 0) {
        let error = NSError(domain: "an error", code: 0)
        imageRequests[index].completion(.failure(error))
    }
}
