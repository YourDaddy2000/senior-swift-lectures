//
//  Extension+FeedStoreSpecs.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 03.11.2021.
//

import XCTest
import EssentialFeed

extension FeedStoreSpecs where Self: XCTestCase {
    func assertThatRetrieveDeliversEmptyOnEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func assertThatRetrieveHasNoSideEffectsOnEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieveTwice: .success(.empty))
    }
    
    func assertThatRetrieveDeliversFoundValuesOnNonEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) {
        let localFeed = uniqueImageFeed.local
        let timestamp = Date()
        
        insert((localFeed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .success(.found(feed: localFeed, timestamp: timestamp)))
    }
    
    func assertThatRetrieveHasNoSideEffectsOnNonEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) {
        let localFeed = uniqueImageFeed.local
        let timestamp = Date()
        
        insert((localFeed, timestamp), to: sut)
        
        expect(sut, toRetrieveTwice: .success(.found(feed: localFeed, timestamp: timestamp)))
    }
    
    func assertThatRetrieveDeliversFailureOnRetrievalError(on sut: FeedStoreProtocol, storeURL: URL, file: StaticString = #file, line: UInt = #line) {
        try! "Invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieve: .failure(anyError()))
    }
    
    func assertThatRetrieveHasNoSideEffectsOnFailure(on sut: FeedStoreProtocol, storeURL: URL, file: StaticString = #file, line: UInt = #line) {
        try! "Invalid Data".write(to: storeURL, atomically: false, encoding: .utf8)
        
        expect(sut, toRetrieveTwice: .failure(anyError()))
    }
    
    func assertThatInsertDeliversNoErrorOnEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) {
        let insertionError = insert((uniqueImageFeed.local, Date()), to: sut)
        XCTAssertNil(insertionError, "expected to insert cache successfully")
    }
    
    func assertThatInsertDeliversNoErrorOnNonEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeed.local, Date()), to: sut)
        
        let insertionError = insert((uniqueImageFeed.local, Date()), to: sut)
        XCTAssertNil(insertionError, "expected to override cache¨ successfully")
    }
    
    func assertThatInsertOverridesPreviouslyInsertedCacheValues(on sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeed.local, Date()), to: sut)
        
        let latestFeed = uniqueImageFeed.local
        let latestTimestamp = Date()
        insert((latestFeed, latestTimestamp), to: sut)
        
        expect(sut, toRetrieve: .success(.found(feed: latestFeed, timestamp: latestTimestamp)))
    }
    
    func assertThatInsertDeliversErrorOnInsertionError(on sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed.local
        let timestamp = Date()
        
        let insertionError = insert((feed, timestamp), to: sut)
        XCTAssertNotNil(insertionError)
    }
    
    func assertThatInsertHasNoSideEffectsOnInsertionError(on sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) {
        let feed = uniqueImageFeed.local
        let timestamp = Date()
        
        insert((feed, timestamp), to: sut)
        
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func assertThatDeleteDeliversNoErrorOnEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) {
        let deletionError = deleteCache(from: sut)
        
        XCTAssertNil(deletionError, "expected sut to succeed deletion")
    }
    
    func assertThatDeleteHasNoSideEffectsOnEmptyCache(on sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeed.local, Date()), to: sut)
        
        let deletionError = deleteCache(from: sut)
        XCTAssertNil(deletionError, "expected sut to succeed deletion")
    }
    
    func assertThatDeleteEmptiesPreviouslyInsertedCache(on sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) {
        insert((uniqueImageFeed.local, Date()), to: sut)
        deleteCache(from: sut)
        
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func assertThatDeleteHasNoSideEffectsOnDeletionError(on sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) {
        deleteCache(from: sut)
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func assertThatDeleteDeliversErrorOnDeletionError(on sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) {
        deleteCache(from: sut)
        expect(sut, toRetrieve: .success(.empty))
    }
    
    func assertThatStoreSideEffectsRunSerially(on sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) {
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
    
    @discardableResult
    func deleteCache(from sut: FeedStoreProtocol) -> Error? {
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
    func insert(_ cache: (feed: [LocalFeedImage], timestamp: Date), to sut: FeedStoreProtocol, file: StaticString = #file, line: UInt = #line) -> Error? {
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
    
    func expect(_ sut: FeedStoreProtocol, toRetrieveTwice expectedResult: FeedStoreProtocol.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        expect(sut, toRetrieve: expectedResult)
        expect(sut, toRetrieve: expectedResult)
    }
    
    func expect(_ sut: FeedStoreProtocol, toRetrieve expectedResult: FeedStoreProtocol.RetrievalResult, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "Wait for cache retrieval")
        
        sut.retrieve { retrievedResult in
            switch (expectedResult, retrievedResult) {
            case (.success(.empty), .success(.empty)),
                (.failure, .failure):
                break
            case let (.success(.found(expectedFeed, expectedTimestamp)), .success(.found(retrievedFeed, retrievedTimestamp))):
                XCTAssertEqual(expectedFeed, retrievedFeed)
                XCTAssertEqual(expectedTimestamp, retrievedTimestamp)
            default: break
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
}
