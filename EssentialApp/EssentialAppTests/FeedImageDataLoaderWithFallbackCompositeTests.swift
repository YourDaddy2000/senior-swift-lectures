//
//  FeedImageDataLoaderWithFallbackCompositeTests.swift
//  EssentialAppTests
//
//  Created by Roman Bozhenko on 15.02.2022.
//

import XCTest
import EssentialFeed

public final class FeedImageDataLoaderWithFallbackComposite: FeedImageDataLoader {
    private let primary: FeedImageDataLoader
    
    private class Task: FeedImageDataLoaderTask {
        func cancel() {
            
        }
    }
    
    public init(primary: FeedImageDataLoader, fallback: FeedImageDataLoader) {
        self.primary = primary
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        _ = primary.loadImageData(from: url, completion: completion)
        return Task()
    }
}

class FeedImageDataLoaderWithFallbackCompositeTests: XCTestCase {

    func test_init_doesNotLoadData() {
        let (_, primaryLoader, fallbackLoader) = makeSUT()
        
        XCTAssertTrue(primaryLoader.loadedURLs.isEmpty)
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty)
    }
    
    func test_loadImageData_loadsFromPrimaryLoaderFirst() {
        let url = anyURL
        let (sut, primaryLoader, fallbackLoader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertTrue(primaryLoader.loadedURLs == [url])
        XCTAssertTrue(fallbackLoader.loadedURLs.isEmpty)
    }
    
    //MARK: - Helpers
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (FeedImageDataLoaderWithFallbackComposite, LoaderSpy, LoaderSpy) {
        let primaryLoader = LoaderSpy()
        let fallbackLoader = LoaderSpy()
        let sut = FeedImageDataLoaderWithFallbackComposite(primary: primaryLoader, fallback: fallbackLoader)
        
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(primaryLoader, file: file, line: line)
        trackForMemoryLeaks(fallbackLoader, file: file, line: line)
        
        return (sut, primaryLoader, fallbackLoader)
        
    }
    
    private class LoaderSpy: FeedImageDataLoader {
        private var messages = [(url: URL, completion: (FeedImageDataLoader.Result) -> Void)]()
        
        var loadedURLs: [URL] {
            messages.map { $0.url }
        }
        
        private struct Task: FeedImageDataLoaderTask {
            func cancel() { }
        }
        
        func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
            messages.append((url, completion))
            return Task()
        }
    }
}
