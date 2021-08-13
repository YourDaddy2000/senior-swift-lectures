//
//  RemoteFeedLoaderTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 13.08.2021.
//

import XCTest

class RemoteFeedLoader {
    let client: HTTPClient
    let url: URL
    
    init(url: URL, client: HTTPClient) {
        self.client = client
        self.url = url
    }
    
    func load() {
        client.get(from: URL(string: "https://a-url.com")!)
    }
}

protocol HTTPClient {
    func get(from url: URL)
}

class RemoteFeedLoaderTests: XCTestCase {
    func test_init_doesNotRequestDataFromURL() {
        let client = HTTPClientSpy()
        
        XCTAssertNil(client.requestedURL)
    }
    
    func test_load_requestDataFromURL() {
        let (sut, client) = getSUT()
        
        sut.load()
        
        XCTAssertNotNil(client.requestedURL)
    }
    
    //MARK: Helpers
    private func getSUT(url: URL = URL(string: "https://google.com")!) -> (sut: RemoteFeedLoader, client: HTTPClientSpy) {
        let client = HTTPClientSpy()
        let sut = RemoteFeedLoader(url: url, client: client)
        
        return (sut, client)
        
    }
    
    private class HTTPClientSpy: HTTPClient {
        func get(from url: URL) {
            requestedURL = url
        }
        
        var requestedURL: URL?
    }
}
