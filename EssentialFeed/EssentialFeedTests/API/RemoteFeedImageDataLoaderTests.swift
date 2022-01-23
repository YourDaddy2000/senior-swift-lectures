//
//  RemoteFeedImageDataLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 23.01.2022.
//

import XCTest
import EssentialFeed

final class RemoteFeedImageDataLoader {
    private let client: HTTPClient
    
    init(client: HTTPClient) {
        self.client = client
    }
    
    func loadImageData(from url: URL, completion: @escaping (FeedImageDataLoader.Result) -> Void) {
        client.get(from: url) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case _:
                break
            }
        }
    }
}


class RemoteFeedImageDataLoaderTests: XCTestCase {

    func test_init_doesNotMessageStore() {
        let (_, spy) = makeSUT()
        XCTAssertEqual(spy.requestedURLs, [])
    }
    
    func test_load_requestsDataFromURL() {
        let (sut, spy) = makeSUT()
        let url = anyURL()
        sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(spy.requestedURLs, [url])
    }
    
    func test_loadImageFromURLTwice_requestsDataFromURLTwice() {
        let (sut, spy) = makeSUT()
        let url = anyURL()
        sut.loadImageData(from: url) { _ in }
        sut.loadImageData(from: url) { _ in }
        XCTAssertEqual(spy.requestedURLs, [url, url])
    }
    
    func test_loadImageFromURL_deliversErrorOnClientError() {
        let (sut, spy) = makeSUT()
        let error = NSError(domain: "client error", code: 0)
        
        expect(sut, toCompleteWith: .failure(error), when: {
            spy.complete(withError: error)
        })
    }
    
    //MARK: - Helpers
    private func makeSUT() -> (RemoteFeedImageDataLoader, HTTPClientSpy) {
        let spy = HTTPClientSpy()
        let sut = RemoteFeedImageDataLoader(client: spy)
        trackForMemoryLeaks(spy)
        trackForMemoryLeaks(sut)
        return (sut, spy)
    }
    
    private func expect(_ sut: RemoteFeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let url = anyURL()
        let exp = expectation(description: "wait for completion")
        
        sut.loadImageData(from: url) { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let receivedData), .success(let expectedData)):
                XCTAssertEqual(receivedData, expectedData, file: file, line: line)
            case (.failure(let receivedError as NSError), .failure(let expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            default:
                XCTFail("Expected result \(expectedResult) got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1)
    }
    
    private class HTTPClientSpy: HTTPClient {
        private var messages = [(url: URL, completion: (Response) -> Void)]()
        var requestedURLs: [URL] { messages.map { $0.url }}
        
        func get(from url: URL, completion: @escaping (Response) -> Void) {
            messages.append((url, completion))
        }
        
        func complete(withError error: Error, at index: Int = 0) {
            messages[index].completion(.failure(error))
        }
    }
}
