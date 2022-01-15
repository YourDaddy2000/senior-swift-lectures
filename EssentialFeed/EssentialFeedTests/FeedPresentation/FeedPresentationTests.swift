//
//  FeedPresentationTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 15.01.2022.
//

import XCTest

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }
}

protocol FeedErrorViewProtocol {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private let errorView: FeedErrorViewProtocol
    
    init(errorView: FeedErrorViewProtocol) {
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
    }
}

class FeedPresentationTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let (_, spy) = makeSUT()
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    func test_didStartLoadingFeed_displaysNoErrorMessage() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoadingFeed()
        XCTAssertEqual(view.messages, [.display(errorMessage: .none)])
    }

    
    //MARK: - Helpers
    private func makeSUT() -> (FeedPresenter, ViewSpy) {
        let viewSpy = ViewSpy()
        let presenter = FeedPresenter(errorView: viewSpy)
        trackForMemoryLeaks(viewSpy)
        trackForMemoryLeaks(presenter)
        
        return (presenter, viewSpy)
    }
    
    private class ViewSpy: FeedErrorViewProtocol {
        enum Messages: Equatable {
            case display(errorMessage: String?)
        }
        
        var messages = [Messages]()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
    }
}
