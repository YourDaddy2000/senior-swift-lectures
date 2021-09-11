//
//  XCTest+Extension.swift
//  EssentialFeedTests
//
//  Created by Roman Bozhenko on 11.09.2021.
//

import XCTest

extension XCTestCase {
    func trackForMemoryLeaks(_ object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, file: file, line: line)
        }
    }
}
