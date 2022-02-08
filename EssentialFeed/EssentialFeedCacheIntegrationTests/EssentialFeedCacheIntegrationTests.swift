//
//  EssentialFeedCacheIntegrationTests.swift
//  EssentialFeedCacheIntegrationTests
//
//  Created by Roman Bozhenko on 13.11.2021.
//

import XCTest
@testable import EssentialFeed

class EssentialFeedCacheIntegrationTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        setupEmptyStore()
    }
    
    override func tearDown() {
        super.tearDown()
        
        undoStoreSideEffects()
    }

    func test_loadFeed_deliversNoItemsOnEmptyCache() {
        let feedLoader = makeFeedLoader()
        
        expect(feedLoader, toLoad: [])
    }
    
    func test_loadFeed_deliversItemsSavedOnASeparateInstance() {
        let feedLoaderToPerformSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let feed = uniqueImageFeed.models
        
        save(feed, with: feedLoaderToPerformSave)
        
        expect(feedLoaderToPerformSave, toSave: feed)
        expect(feedLoaderToPerformLoad, toLoad: feed)
    }
    
    func test_saveFeed_overridesItemsSavedOnASeparateInstance() {
        let feedLoaderToPerformFirstSave = makeFeedLoader()
        let feedLoaderToPerformLastSave = makeFeedLoader()
        let feedLoaderToPerformLoad = makeFeedLoader()
        let firstFeed = uniqueImageFeed.models
        let latestFeed = uniqueImageFeed.models
        
        expect(feedLoaderToPerformFirstSave, toSave: firstFeed)
        expect(feedLoaderToPerformLastSave, toSave: latestFeed)
        
        expect(feedLoaderToPerformLoad, toLoad: latestFeed)
    }
    
    // MARK: - LocalFeedImageDataLoader Tests
    func test_loadImageData_deliversSavedDataOnASeparateInstance() {
        let imageLoaderToPerformSave = makeImageLoader()
        let imageLoaderToPerformLoad = makeImageLoader()
        let feedLoader = makeFeedLoader()
        let image = uniqueImage()
        let dataToSave = anyData()
        
        save([image], with: feedLoader)
        save(dataToSave, for: image.url, with: imageLoaderToPerformSave)
        
        expect(imageLoaderToPerformLoad, toLoad: dataToSave, for: image.url)
    }
    
    //MARK: - Helpers
    
    private func save(_ data: Data, for url: URL, with loader: LocalFeedImageDataLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "wait for save completion")
        
        loader.save(data, for: url) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save image data successfully, got error: \(error)", file: file, line: line)
            }
            
            saveExp.fulfill()
        }
        
        wait(for: [saveExp], timeout: 1)
    }
    
    private func expect(_ sut: LocalFeedImageDataLoader, toLoad expectedData: Data, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let loadExp = expectation(description: "wait for load completion")
        _ = sut.loadImageData(from: url) { result in
            switch result {
            case .success(let receivedData):
                XCTAssertEqual(expectedData, receivedData, file: file, line: line)
                
            case .failure(let error):
                XCTFail("Expected successful image data result, got \(error) instead", file: file, line: line)
            }
            
            loadExp.fulfill()
        }
        
        wait(for: [loadExp], timeout: 1)
    }
    
    private func makeImageLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedImageDataLoader {
        let storeURL = testSpecificStoreURL
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedImageDataLoader(store: store)
        trackForMemoryLeaks(store)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func expect(_ sut: LocalFeedLoader, toSave expectedResult: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for save completion")
        
        sut.save(expectedResult) { saveResult in
            if case let Result.failure(error) = saveResult {
                XCTAssertNil(error, "expected no errors, got \(error) instead", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func expect(_ sut: LocalFeedLoader, toLoad expectedFeed: [FeedImage], file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        
        sut.load { receivedResult in
            switch receivedResult {
            case let .success(loadedFeed):
                XCTAssertEqual(loadedFeed, expectedFeed, file: file, line: line)
            case let .failure(error):
                XCTFail("expected success, got \(error) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func makeFeedLoader(file: StaticString = #file, line: UInt = #line) -> LocalFeedLoader {
        let storeURL = testSpecificStoreURL
        let store = try! CoreDataFeedStore(storeURL: storeURL)
        let sut = LocalFeedLoader(store: store, currentDate: Date.init)
        trackForMemoryLeaks(store, file: file, line: line)
        trackForMemoryLeaks(sut, file: file, line: line)
        return sut
    }
    
    private func save(_ feed: [FeedImage], with loader: LocalFeedLoader, file: StaticString = #file, line: UInt = #line) {
        let saveExp = expectation(description: "Wait for save completion")
        loader.save(feed) { result in
            if case let Result.failure(error) = result {
                XCTFail("Expected to save feed successfully, got error: \(error)", file: file, line: line)
            }
            saveExp.fulfill()
        }
        wait(for: [saveExp], timeout: 1.0)
    }
    
    private var testSpecificStoreURL: URL {
        cachesDirectory.appendingPathComponent("\(type(of: self)).store")
    }
    
    private var cachesDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }

    private func setupEmptyStore() {
        deleteStoreArtifacts()
    }
    
    private func undoStoreSideEffects() {
        deleteStoreArtifacts()
    }
    
    func deleteStoreArtifacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }
    
}
