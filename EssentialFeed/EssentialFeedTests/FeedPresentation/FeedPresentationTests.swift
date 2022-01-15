//
//  FeedPresentationTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 15.01.2022.
//

import XCTest

final class FeedPresenter {
    
    init(view: Any) {
        
    }
}

class FeedPresentationTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let spy = makeSUT()
        _ = FeedPresenter(view: spy)
        XCTAssertTrue(spy.messages.isEmpty)
    }

    
    //MARK: - Helpers
    private func makeSUT() -> (ViewSpy) {
        let viewSpy = ViewSpy()
        trackForMemoryLeaks(viewSpy)
        
        return (viewSpy)
    }
    
    private class ViewSpy {
        let messages = [Any]()
    }
}
