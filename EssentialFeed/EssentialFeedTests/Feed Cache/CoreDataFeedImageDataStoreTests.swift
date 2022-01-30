//
//  CoreDataFeedImageDataStoreTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 30.01.2022.
//

import XCTest
@testable import EssentialFeed

extension CoreDataFeedStore: FeedImageDataStore {
    public func insert(_ data: Data, for url: URL, completion: @escaping (FeedImageDataStore.InsertionResult) -> Void) {
        
    }
    
    public func retrieve(dataForURL url: URL, completion: @escaping (FeedImageDataStore.RetrievalResult) -> Void) {
        completion(.success(.none))
    }
}

class CoreDataFeedImageDataStoreTests: XCTestCase {

    func test_retrieveImageData_deliversNotFoundWhenEmpty() {
        let sut = makeSUT()
        
        expect(sut, toCompleteWith: notFound(), for: anyURL())
    }
    
    func test_retrieveImageData_deliversNotFoundWhenStoreDataURLDoesNotMatch() {
        let sut = makeSUT()
        let url = anyURL()
        let nonMatchingURL = URL(string: "https://not-matching-url.com")!
        insert(anyData(), for: url, into: sut)
        
        expect(sut, toCompleteWith: notFound(), for: nonMatchingURL)
    }
    
    //MARK: - Helpers
    private func notFound() -> FeedImageDataStore.RetrievalResult {
        return .success(.none)
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
                }
            case .failure(let error):
                XCTFail("Failed to save \(image) with error \(error)", file: file, line: line)
            }
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
    
    private func expect(_ sut: CoreDataFeedStore, toCompleteWith expectedResult: FeedImageDataStore.RetrievalResult, for url: URL, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        sut.retrieve(dataForURL: anyURL()) { receivedResult in
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
