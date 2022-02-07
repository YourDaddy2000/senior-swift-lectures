//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 30.01.2022.
//

import XCTest
@testable import EssentialFeed

class CoreDataFeedImageDataStoreTests: XCTestCase {

    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        let url = URL(string: "https://wrong-url.com")!
        
        expect(sut, toCompleteWith: notFound(), for: url)
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoreDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = anyURL()
        let nonMatchingURL = URL(string: "https://not-matching-url.com")!
        insert(anyData(), for: url, into: sut)

        expect(sut, toCompleteWith: notFound(), for: nonMatchingURL)
    }
    
    func test_retrieveImageData_deliversFoundDataWhenThereIsAStoredImageMatchingURL() {
        let sut = makeSUT()
        let storedData = anyData()
        let matchingURL = anyURL()
        
        insert(storedData, for: matchingURL, into: sut)
        
        expect(sut, toCompleteWith: found(storedData), for: matchingURL)
    }
    
    func test_retrieveImageData_deliversLastInsertedValue() {
        let sut = makeSUT()
        let firstStoredData = Data("first".utf8)
        let lastStoredData = Data("last".utf8)
        let url = URL(string: "http://a-url.com")!
        
        insert(firstStoredData, for: url, into: sut)
        insert(lastStoredData, for: url, into: sut)
        
        expect(sut, toCompleteWith: found(lastStoredData), for: url)
    }
    
    func test_sideEffects_runSerially() {
        let sut = makeSUT()
        let url = anyURL()
        
        let op1 = expectation(description: "Operation 1")
        sut.insert([localImage(for: url)], timestamp: Date()) { _ in
            op1.fulfill()
        }
        
        let op2 = expectation(description: "Operation 2")
        sut.insert(anyData(), for: url) { _ in op2.fulfill() }
        
        let op3 = expectation(description: "Operation 2")
        sut.insert(anyData(), for: url) { _ in op3.fulfill() }
        
        wait(for: [op1, op2, op3], timeout: 5, enforceOrder: true)
    }
    
    //MARK: - Helpers
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
    }
    
    private func found(_ data: Data) -> FeedImageDataStore.RetrievalResult {
        .success(data)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> CoreDataFeedStore {
        let storeBundle = Bundle(for: CoreDataFeedStore.self)
        let storeURL = URL(fileURLWithPath: "dev/null")
        let sut = try! CoreDataFeedStore(storeURL: storeURL, bundle: storeBundle)
        trackForMemoryLeaks(sut)
        return sut
    }
    
    private func localImage(for url: URL) -> LocalFeedImage {
        LocalFeedImage(id: UUID(), description: "any", location: "any", imageURL: url)
    }
    
    private func insert(_ data: Data, for url: URL, into sut: CoreDataFeedStore, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for cache insertion")
        let image = localImage(for: url)
        
        sut.insert([image], timestamp: Date()) { result in
            switch result {
            case .success:
                sut.insert(data, for: url) { result in
                    if case let Result.failure(error) = result {
                        XCTFail("Failed to insert \(data) with error \(error)", file: file, line: line)
                    }
                    exp.fulfill()
                }
            case .failure(let error):
                XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
                exp.fulfill()
            }
        }
        
        wait(for: [exp], timeout: 5)
    }
    
    private func expect(_ sut: CoreDataFeedStore, toCompleteWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        sut.retrieve(dataForURL: url) { receivedResult in
            switch (expectedResult, receivedResult) {
            case (.success(let expectedData), .success(let receivedData)):
                XCTAssertEqual(expectedData, receivedData, file: file, line: line)
            default:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
}
