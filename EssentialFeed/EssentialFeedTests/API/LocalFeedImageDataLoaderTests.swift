//
//  LocalFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 23.01.2022.
//

import XCTest
import EssentialFeed

final class LocalFeedImageLoader {
    init(store: Any) {
        
    }
}

class LocalFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotMessageStoreUponCreation() {
        let (_, spy) = makeSUT()
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    //MARK: - Helpers
    private func makeSUT() -> (LocalFeedImageLoader, FeedStoreSpy) {
        let spy = FeedStoreSpy()
        let sut = LocalFeedImageLoader(store: spy)
        trackForMemoryLeaks(spy)
        trackForMemoryLeaks(sut)
        return (sut, spy)
    }
    
    private class FeedStoreSpy {
        var messages = [Any]()
    }
}
