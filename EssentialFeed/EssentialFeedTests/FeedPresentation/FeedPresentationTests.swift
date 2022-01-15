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

struct FeedLoadingViewModel {
    let isLoading: Bool?
}

protocol LoadingViewProtocol {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedErrorViewProtocol {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private let errorView: FeedErrorViewProtocol
    private let loadingView: LoadingViewProtocol
    
    init(loadingView: LoadingViewProtocol, errorView: FeedErrorViewProtocol) {
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
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
        XCTAssertEqual(view.messages, [
            .display(errorMessage: .none),
            .display(isLoading: true)
        ])
    }

    
    //MARK: - Helpers
    private func makeSUT() -> (FeedPresenter, ViewSpy) {
        let viewSpy = ViewSpy()
        let presenter = FeedPresenter(loadingView: viewSpy, errorView: viewSpy)
        trackForMemoryLeaks(viewSpy)
        trackForMemoryLeaks(presenter)
        
        return (presenter, viewSpy)
    }
    
    private class ViewSpy: FeedErrorViewProtocol, LoadingViewProtocol {
        enum Messages: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool?)
        }
        
        var messages = [Messages]()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
    }
}
