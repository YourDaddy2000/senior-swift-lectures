//
//  FeedImageDataLoaderCacheDecoratorTests.swift
//  EssentialAppTests
//
//  Created by Roman Bozhenko on 20.02.2022.
//

import XCTest
import EssentialFeed

public final class FeedImageDataLoaderCacheDecorator: FeedImageDataLoader {
    private let decoratee: FeedImageDataLoader
    
    public init(decoratee: FeedImageDataLoader) {
        self.decoratee = decoratee
    }
    
    public func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) -> FeedImageDataLoaderTask {
        decoratee.loadImageData(from: url, completion: completion)
    }
}

class FeedImageDataLoaderCacheDecoratorTests: XCTestCase, FeedImageDataLoaderTestsProtocol {

    func test_loadImageData_doesNotLoadImageDataOnInit() {
        let (_, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadedURLs, [])
    }
    
    func test_loadImageData_loadsFromLoader() {
        let url = anyURL
        let (sut, loader) = makeSUT()
        
        _ = sut.loadImageData(from: url) { _ in }
        
        XCTAssertEqual(loader.loadedURLs, [url])
    }
    
    func test_cancelLoadImageData_cancelsLoaderTask() {
        let url = anyURL
        let (sut, loader) = makeSUT()
        
        let task = sut.loadImageData(from: url) { _ in }
        task.cancel()
        
        XCTAssertEqual(loader.cancelledURLs, [url])
    }
    
    func test_loadImageData_deliversDataOnLoaderSuccess() {
        let imageData = anyData
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .success(imageData), when: {
            loader.complete(with: imageData)
        })
    }
    
    func test_loadImageData_deliversErrorOnLoaderFailure() {
        let (sut, loader) = makeSUT()
        
        expect(sut, toCompleteWith: .failure(anyNSError()), when: {
            loader.complete(with: anyNSError())
        })
    }
    
    //MARK: - Helper
    private func makeSUT() -> (FeedImageDataLoaderCacheDecorator, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedImageDataLoaderCacheDecorator(decoratee: loader)
        
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        
        return (sut, loader)
    }
}
