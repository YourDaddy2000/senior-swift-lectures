//
//  FeedEndpointTests.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 04.06.2022.
//

import XCTest
import EssentialFeed

class FeedEndpointTests: XCTestCase {

    func test_feed_endpointURL() {
        let baseURL = URL(string: "http://base-url.com")!

        let received = FeedEndpoint.get().url(baseURL: baseURL)
        XCTAssertEqual(received.scheme, baseURL.scheme)
        XCTAssertEqual(received.host, baseURL.host)
        XCTAssertEqual(received.path, "/v1/feed")
        XCTAssertEqual(received.query, "limit=10")
    }
    
    func test_feed_endpointURLAfterGivenImage() {
        let image = uniqueImage()
        let baseURL = URL(string: "http://base-url.com")!
        
        let received = FeedEndpoint.get(after: image).url(baseURL: baseURL)
        XCTAssertEqual(received.scheme, baseURL.scheme)
        XCTAssertEqual(received.host, baseURL.host)
        XCTAssertEqual(received.path, "/v1/feed")
        XCTAssertEqual(received.query?.contains("limit=10"), true)
        XCTAssertEqual(received.query?.contains("after_id=\(image.id)"), true)
    }
}
