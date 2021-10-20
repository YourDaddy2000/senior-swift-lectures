//
//  XCTest+Extension.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 11.09.2021.
//

import XCTest
import EssentialFeed

extension XCTestCase {
    func trackForMemoryLeaks(_ object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, file: file, line: line)
        }
    }
    
    func anyURL() -> URL {
        return URL(string: "https://any-url.com")!
    }
    
    func anyData() -> Data {
        return Data("any data".utf8)
    }
    
    func anyError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
    func uniqueImage() -> FeedImage {
        return FeedImage(id: UUID(), description: "any", location: "any", url: anyURL())
    }
    
    var uniqueImageFeed: (models: [FeedImage], local: [LocalFeedImage]) {
        let models = [uniqueImage(), uniqueImage()]
        let localItems = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, imageURL: $0.url) }
        return (models, localItems)
    }
}

extension Date {
    func minusFeedCacheMaxAge() -> Date {
        return adding(days: -feedCacheMaxAgeInDays)
    }
    
    private var feedCacheMaxAgeInDays: Int { 7 }
    
    private func adding(days: Int) -> Date {
        Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
    }
}

extension Date {
    func adding(seconds: TimeInterval) -> Date {
        self + seconds
    }
}
