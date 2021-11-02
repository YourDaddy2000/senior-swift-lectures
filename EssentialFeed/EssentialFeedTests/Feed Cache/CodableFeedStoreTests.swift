//
//  CodableFeedStoreTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 20.10.2021.
//

import XCTest
import EssentialFeed

class CodableFeedStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        
        deleteStoreArtefacts()
    }
    
    override func tearDown() {
        super.tearDown()
        
        deleteStoreArtefacts()
    }

    func test_retrieve_deliversEmptyOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieve: .empty)
    }
    
    func test_retrieve_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        expect(sut, toRetrieveTwice: .empty)
    }
    
    func test_retrieve_deliversFoundValuesOnNonEmptyCache() {
        let sut = makeSUT()
        let localFeed = uniqueImageFeed.local
        let timestamp = Date()
        
        insert((localFeed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .found(feed: localFeed, timestamp: timestamp))
    }
    
    func test_retrieve_hasNoSideEffectsOnNonEmptyCache() {
        let sut = makeSUT()
        let localFeed = uniqueImageFeed.local
        let timestamp = Date()
        
        insert((localFeed, timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .found(feed: localFeed, timestamp: timestamp))
    }
    
    func test_retrieve_deliversFailureOnRetrievalError() {
        let storeURL = testSpecificStoreURL
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyError()))
    }
    
    func test_retrieve_hasNoSideEffectsOnFailure() {
        let storeURL = testSpecificStoreURL
        let sut = makeSUT(storeURL: storeURL)
        
        try! "Invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyError()))
    }
    
    func test_insert_overridesPreviouslyInsertedCacheValues() {
        let sut = makeSUT()
        
        let firstInsertionError = insert((uniqueImageFeed.local, Date()), to: sut)
        XCTAssertNil(firstInsertionError, "Expected to insert cache successfully")
        
        let latestFeed = uniqueImageFeed.local
        let timestamp = Date()
        let latestInsertionError = insert((latestFeed, timestamp), to: sut)
        
        XCTAssertNil(latestInsertionError)
        expect(sut, toRetrieve: .found(feed: latestFeed, timestamp: timestamp))
    }
    
    func test_insert_deliversErrorOnInsertionError() {
        let invalidStoreURL = URL(string: "invalid://url")!
        let sut = makeSUT(storeURL: invalidStoreURL)
        let feed = uniqueImageFeed.local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        XCTAssertNotNil(insertionError)
    }
    
    func test_delete_hasNoSideEffectsOnEmptyCache() {
        let sut = makeSUT()
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "expected sut to succeed deletion")
        expect(sut, toRetrieve: .empty)
    }
    
    func test_delete_emptiesPreviouslyInsertedCache() {
        let sut = makeSUT()
        insert((uniqueImageFeed.local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "expected sut to succeed non-empty cache deletion")
        expect(sut, toRetrieve: .empty)
    }
    
    #warning("https://academy.essentialdeveloper.com/courses/447455/lectures/10675368/comments/7321729")
//    func test_delete_deliversErrorOnDeletionError() {
//        let noDeletePermissionURL = cachesDirectory
//        let sut = makeSUT(storeURL: noDeletePermissionURL)
//
//        let deletionError = deleteCache(from: sut)
//        XCTAssertNotNil(deletionError, "expected sut to fail cache deletion")
//    }
    
    func test_storeSideEffects_runSerially() {
        let sut = makeSUT()
        var completedOperationsInOrder = [XCTestExpectation]()
        
        let exp1 = expectation(description: "Operation 1")
        sut.insert(uniqueImageFeed.local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(exp1)
            exp1.fulfill()
        }
        
        let exp2 = expectation(description: "Operation 2")
        sut.deleteCachedFeed { _ in
            completedOperationsInOrder.append(exp2)
            exp2.fulfill()
        }
        
        let exp3 = expectation(description: "Operation 3")
        sut.insert(uniqueImageFeed.local, timestamp: Date()) { _ in
            completedOperationsInOrder.append(exp3)
            exp3.fulfill()
        }
        
        waitForExpectations(timeout: 5.0)
        
        XCTAssertEqual(completedOperationsInOrder, [exp1, exp2, exp3], "expected side effects to run serially but operations finished in the wrong order")
    }
    
    //MARK: - Helpers
    private func deleteCache(from sut: FeedStoreProtocol) -> Error? {
        let exp = expectation(description: "wait for deletion completion")
        
        var deletionError: Error?
        sut.deleteCachedFeed { receivedError in
            deletionError = receivedError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 5)
        
        return deletionError
    }
    
    @discardableResult
    private func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) -> Error? {
        let exp = expectation(description: "wait for completion")
        var insertionError: Error?
        sut.insert(cache.feed, timestamp: cache.timestamp) { receivedInsertionError in
            XCTAssertNil(insertionError, "Expected Feed to be inserted successfully")
            insertionError = receivedInsertionError
            exp.fulfill()
        }
        wait(for: [exp], timeout: 1)
        return insertionError
    }
    
    private func expect(_ sut: FeedStoreProtocol, toRetrieveTwice expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    private func expect(_ sut: FeedStoreProtocol, toRetrieve expectedResult: RetrieveCachedFeedResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.empty, .empty),
                (.failure, .failure):
                break
            case let (.found(expected), .found(retrieved)):
                XCTAssertEqual(expected.feed, retrieved.feed)
                XCTAssertEqual(expected.timestamp, retrieved.timestamp)
            default: break
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private var testSpecificStoreURL: URL {
        cachesDirectory.appendingPathComponent("\(type(of: self)).store")
    }
    
    private var cachesDirectory: URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
    
    private func deleteStoreArtefacts() {
        try? FileManager.default.removeItem(at: testSpecificStoreURL)
    }
    
    private func makeSUT(storeURL: URL? = nil, file: StaticString = #file, line: UInt = #line) -> FeedStoreProtocol {
        let sut = CodableFeedStore(storeURL: storeURL ?? testSpecificStoreURL)
        trackForMemoryLeaks(sut)
        
        return sut
    }
}
