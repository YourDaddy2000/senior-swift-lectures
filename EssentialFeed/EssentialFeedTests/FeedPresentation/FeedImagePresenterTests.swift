//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 15.01.2022.
//

import XCTest
import EssentialFeed

struct FeedImageViewModel {
    let description: String?
    let location: String?
    let image: Any?
    let isLoading: Bool
    let shouldRetry: Bool
    
    var hasLocation: Bool {
        return location != nil
    }
}

protocol FeedImageViewProtocol {
    func display(_ viewModel: FeedImageViewModel)
}

final class FeedImagePresenter {
    let view: FeedImageViewProtocol
    let imageTransformer: (Data) -> Any?
    init(view: FeedImageViewProtocol, imageTransformer: @escaping (Data) -> Any?) {
        self.view = view
        self.imageTransformer = imageTransformer
    }
    
    func didStartLoadingData(for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: nil,
            isLoading: true,
            shouldRetry: false)
        )
    }
    
    func didFinishLoadingImageData(with data: Data, for model: FeedImage) {
        view.display(FeedImageViewModel(
            description: model.description,
            location: model.location,
            image: imageTransformer(data),
            isLoading: false,
            shouldRetry: true))
    }
}

class FeedImagePresenterTests: XCTestCase {

    func test_init_doesNotSendMessagesToView() {
        let (_, spy) = makeSUT()
        XCTAssertTrue(spy.messages.isEmpty)
    }
    
    func test_didStartLoadingData_displaysLoadingImage() {
        let (sut, view) = makeSUT()
        let image = uniqueImage()
        
        sut.didStartLoadingData(for: image)
        let message = view.messages.first
        
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, true)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertNil(message?.image)
    }
    
    func test_didFinishLoadingImageData_displaysRetryOnFailedImageTransformation() {
        let (sut, view) = makeSUT(imageTransformer: fail)
        let image = uniqueImage()
        let data = Data()
        
        sut.didFinishLoadingImageData(with: data, for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    //MARK: - Helpers
    private var fail: (Data) -> Any? {
        { _ in nil }
    }
    
    private func makeSUT(imageTransformer: @escaping (Data) -> Any? = { _ in nil }) -> (FeedImagePresenter, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        
        return (sut, view)
    }
    
    private class ViewSpy: FeedImageViewProtocol {
        var messages = [FeedImageViewModel]()
        
        func display(_ viewModel: FeedImageViewModel) {
            messages.append(viewModel)
        }
    }

}
