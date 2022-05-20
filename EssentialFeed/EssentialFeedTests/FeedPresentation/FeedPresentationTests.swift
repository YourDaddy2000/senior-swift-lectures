//
//  FeedPresentationTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 15.01.2022.
//

import XCTest
@testable import EssentialFeed

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
    
    func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoading(with: anyError())
        XCTAssertEqual(view.messages, [
            .display(errorMessage: localized("GENERIC_CONNECTION_ERROR", table: "Shared")),
            .display(isLoading: false)
        ])
    }
    
    func test_title_isLocalized() {
        XCTAssertEqual(FeedPresenter.title, localized("feed_view_title"))
    }
    
    //MARK: - Helpers
    private func localized(_ key: String, table: String = "Feed", file: StaticString = #file, line: UInt = #line) -> String {
        let bundle = Bundle(for: FeedPresenter.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        
        return value
    }
    
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
