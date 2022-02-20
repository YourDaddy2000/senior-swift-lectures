//
//  LoaderSpy.swift
//  EssentialAppTests
//
//  Created by Roman Bozhenko on 20.02.2022.
//

import Foundation
import EssentialFeed

final class LoaderSpy: FeedImageDataLoader {
    private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
    
    private(set) var cancelledURLs = [URL]()
    
    var loadedURLs: [URL] {
        messages.map { $0.url }
    }
    
    private struct Task: FeedImageDataLoaderTask {
        let callBack: () -> Void
        
        func cancel() { callBack() }
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        messages.append((url, completion))
        return Task { [weak self] in self?.cancelledURLs.append(url) }
    }
    
    func complete(with error: NSError, at index: Int = 0) {
        messages[index].completion(.failure(error))
    }
    
    func complete(with data: Data, at index: Int = 0) {
        messages[index].completion(.success(data))
    }
}
