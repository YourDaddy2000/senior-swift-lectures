//
//  FeedImagePresenterTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 15.01.2022.
//

import XCTest
@testable import EssentialFeed

class FeedImagePresenterTests: XCTestCase {
    
    func test_map_createsViewModel() {
        let image = uniqueImage()
        let viewModel = FeedImagePresenter<ViewSpy, AnyImage>.map(image)
        
        XCTAssertEqual(viewModel.description, image.description)
        XCTAssertEqual(viewModel.location, image.location)
    }

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
    
    func test_didFinishLoadingImageData_displaysImageOnSuccessfulTransformation() {
        let image = uniqueImage()
        let data = Data()
        let transformedData = AnyImage()
        let (sut, view) = makeSUT(imageTransformer: { _ in transformedData })
        
        sut.didFinishLoadingImageData(with: data, for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, false)
        XCTAssertEqual(message?.image, transformedData)
    }
    
    func test_didFinishLoadingImageData_displaysRetry() {
        let image = uniqueImage()
        let (sut, view) = makeSUT()
        
        sut.didFinishLoadingImageData(with: anyError(), for: image)
        
        let message = view.messages.first
        XCTAssertEqual(view.messages.count, 1)
        XCTAssertEqual(message?.description, image.description)
        XCTAssertEqual(message?.location, image.location)
        XCTAssertEqual(message?.isLoading, false)
        XCTAssertEqual(message?.shouldRetry, true)
        XCTAssertNil(message?.image)
    }
    
    //MARK: - Helpers
    private var fail: (Data) -> AnyImage? {
        { _ in nil }
    }
    
    private func makeSUT(imageTransformer: @escaping (Data) -> AnyImage? = { _ in nil }) -> (FeedImagePresenter<ViewSpy, AnyImage>, ViewSpy) {
        let view = ViewSpy()
        let sut = FeedImagePresenter(view: view, imageTransformer: imageTransformer)
        trackForMemoryLeaks(view)
        trackForMemoryLeaks(sut)
        
        return (sut, view)
    }
    
    private struct AnyImage: Equatable { }
    
    private class ViewSpy: FeedImageViewProtocol {
        var messages = [FeedImageViewModel<AnyImage>]()
        
        func display(_ viewModel: FeedImageViewModel<AnyImage>) {
            messages.append(viewModel)
        }
    }

}
