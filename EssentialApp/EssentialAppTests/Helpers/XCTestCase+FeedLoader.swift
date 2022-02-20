//
//  XCTestCase+FeedLoader.swift
//  EssentialAppTests
//
//  Created by Roman Bozhenko on 20.02.2022.
//

import Foundation
import EssentialFeed
import XCTest

protocol FeedLoaderTestCase: XCTestCase {}

extension FeedLoaderTestCase {
    func expect(_ sut: FeedLoader, toCompleteWith expectedResult: FeedLoader.Result, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        
        sut.load { receivedResult in
            switch (receivedResult, expectedResult) {
            case (.success(let receivedFeed), .success(let expectedFeed)):
                XCTAssertEqual(receivedFeed, expectedFeed, file: file, line: line)
            
            case (.failure(let receivedError as NSError), .failure(let expectedError as NSError)):
                XCTAssertEqual(receivedError, expectedError, file: file, line: line)
            
            case _: break
            }
            
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 1)
    }
}
