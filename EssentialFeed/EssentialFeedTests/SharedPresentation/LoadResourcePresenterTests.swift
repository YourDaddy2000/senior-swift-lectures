//
//  LoadResourcePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 20.05.2022.
//

import XCTest
import EssentialFeed

class LoadResourcePresenterTests: XCTestCase {
    
    func test_init_doesNotMessageView() {
        let (_, spy) = makeSUT()
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    func test_didStartLoading_displaysNoErrorMessageAndStartsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didStartLoading()
        XCTAssertEqual(view.messages, [
            .display(errorMessage: .none),
            .display(isLoading: true)
        ])
    }

    func test_didFinishLoadingFeed_displaysFeedAndStopsLoading() {
        let (sut, view) = makeSUT(mapper: { resource in
            resource + " view model"
        })
        
        sut.didFinishLoading(with: "resource")
        XCTAssertEqual(view.messages, [
            .display(resourceViewModel: "resource view model"),
            .display(isLoading: false)
        ])
    }
    
    func test_didFinishLoadingFeedWithError_displaysLocalizedErrorMessageAndStopsLoading() {
        let (sut, view) = makeSUT()
        
        sut.didFinishLoading(with: anyError())
        XCTAssertEqual(view.messages, [
            .display(errorMessage: localized("FEED_VIEW_CONNECTION_ERROR")),
            .display(isLoading: false)
        ])
    }
    
    //MARK: - Helpers
    private func localized(_ key: String, file: StaticString = #file, line: UInt = #line) -> String {
        let table = "Feed"
        let bundle = Bundle(for: SUT.self)
        let value = bundle.localizedString(forKey: key, value: nil, table: table)
        
        if value == key {
            XCTFail("Missing localized string for key: \(key) in table: \(table)", file: file, line: line)
        }
        
        return value
    }
    
    private typealias SUT = LoadResourcePresenter<String, ViewSpy>
    
    private func makeSUT(
        mapper: @escaping SUT.Mapper = { _ in "any" },
        file: StaticString = #file,
        line: UInt = #line
    ) -> (SUT, ViewSpy) {
        let viewSpy = ViewSpy()
        let sut = SUT(resourceView: viewSpy, loadingView: viewSpy, errorView: viewSpy, mapper: mapper)
        trackForMemoryLeaks(viewSpy)
        trackForMemoryLeaks(sut)
        
        return (sut, viewSpy)
    }
    
    private class ViewSpy: FeedErrorViewProtocol, LoadingViewProtocol, ResourceViewProtocol {
        typealias ResourceViewModel = String
        
        enum Messages: Equatable {
            case display(errorMessage: String?)
            case display(isLoading: Bool?)
            case display(resourceViewModel: String)
        }
        
        var messages = [Messages]()
        
        func display(_ viewModel: FeedErrorViewModel) {
            messages.append(.display(errorMessage: viewModel.message))
        }
        
        func display(_ viewModel: FeedLoadingViewModel) {
            messages.append(.display(isLoading: viewModel.isLoading))
        }
        
        func display(_ viewModel: String) {
            messages.append(.display(resourceViewModel: viewModel))
        }
    }
}