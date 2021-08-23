//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 13.08.2021.
//

import XCTest
import EssentialFeed

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        
        XCTAssertTrue(client.requestedURLs.isEmpty)
    }
    
    func test_load_requestsDataFromURL() {
        let url = URL(string: "https://someurl.com")!
        let (sut, client) = getSUT(url: url)
        
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url])
    }
    
    func test_load_requestsDataTwiceFromURL() {
        let url = URL(string: "https://someurl.com")!
        let (sut, client) = getSUT(url: url)
        
        sut.load()
        sut.load()
        
        XCTAssertEqual(client.requestedURLs, [url, url])
    }
    
    func test_load_deliversErrorOnClientError() {
        let (sut, client) = getSUT()
        var capturedError: RemoteFeedLoader.Error!
        client.error = NSError(domain: "Test", code: 0)
        
        sut.load { error in capturedError = error }
        
        XCTAssertEqual(capturedError, .connectivityError)
    }
    
    //MARK: Helpers
    private func getSUT(url: URL = URL(string: "https://google.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut, client)
    }
    
    private class HTTPClientSpy: HTTPClient {
        var requestedURLs = [URL]()
        var error: Error?
        
        func get(from url: URL, completion: @escaping (Error) -> Void) {
            if let error = error {
                completion(error)
            }
            requestedURLs.append(url)
        }
    }
}
