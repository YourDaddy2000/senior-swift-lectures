//
//  XCTestCase+FeedImageDataLoader.swift
//  EssentialAppTests
//
//  Created by Roman Bozhenko on 20.02.2022.
//

import Foundation
import XCTest
import EssentialFeed
import EssentialApp

protocol FeedImageDataLoaderTestsProtocol: XCTestCase {}

extension FeedImageDataLoaderTestsProtocol {
    
    func expect(_ sut: FeedImageDataLoader, toCompleteWith expectedResult: FeedImageDataLoader.Result, when action: () -> Void, file: StaticString = #file, line: UInt = #line) {
        let exp = expectation(description: "wait for completion")
        
        _ = sut.loadImageData(from: anyURL) { receivedResult in
            switch(expectedResult, receivedResult) {
            case (.success(let expected), .success(let received)):
                XCTAssertEqual(expected, received)
                
            case (.failure(let expected as NSError), .failure(let received as NSError)):
                XCTAssertEqual(expected, received)
                
            case _:
                XCTFail("Expected \(expectedResult), got \(receivedResult) instead", file: file, line: line)
            }
            
            exp.fulfill()
        }
        
        action()
        wait(for: [exp], timeout: 1)
    }
}
