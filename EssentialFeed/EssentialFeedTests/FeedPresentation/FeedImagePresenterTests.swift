//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 15.01.2022.
//

import XCTest

final class FeedImagePresenter {
    init(view: Any) {
        
    }
}

class FeedImagePresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, spy) = makeSUT()
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    //MARK: - Helpers
    private func makeSUT() -> (FeedImagePresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        
        return (sut, view)
    }
    
    private class ViewSpy {
        var messages = [Any]()
    }

}
