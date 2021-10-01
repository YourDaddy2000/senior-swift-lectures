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
    
    func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
}
