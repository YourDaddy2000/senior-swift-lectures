//
//  FeedPresentationTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 15.01.2022.
//

import XCTest
import EssentialFeed

struct FeedViewModel {
    let feed: [FeedImage]
}

struct FeedErrorViewModel {
    let message: String?
    
    static var noError: FeedErrorViewModel {
        FeedErrorViewModel(message: nil)
    }
}

struct FeedLoadingViewModel {
    let isLoading: Bool?
}

protocol FeedViewProtocol {
    func display(_ viewModel: FeedViewModel)
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
    private let feedView: FeedViewProtocol
    
    init(feedView: FeedViewProtocol, loadingView: LoadingViewProtocol, errorView: FeedErrorViewProtocol) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoading(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
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

    func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
        let (sut, view) = makeSUT()
        let feed = uniqueImageFeed.models
        sut.didFinishLoading(with: feed)
        XCTAssertEqual(view.messages, [
            .display(feed: feed),
            .display(isLoading: false)
        ])
    }
    
    //MARK: - Helpers
    private func makeSUT() -> (FeedPresenter, ViewSpy) {
        let viewSpy = ViewSpy()
        let presenter = FeedPresenter(feedView: viewSpy, loadingView: viewSpy, errorView: viewSpy)
        trackForMemoryLeaks(viewSpy)
        trackForMemoryLeaks(presenter)
        
        return (presenter, viewSpy)
    }
    
    private class ViewSpy: FeedErrorViewProtocol, LoadingViewProtocol, FeedViewProtocol {
        enum Messages: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool?)
            case display(feed: [FeedImage])
        }
        
        var messages = [Messages]()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: FeedViewModel) {
            messages.append(.display(feed: viewModel.feed))
        }
    }
}
