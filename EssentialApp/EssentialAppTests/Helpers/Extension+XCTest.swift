//
//  Extension+XCTest.swift
//  EssentialAppTests
//
//  Created by Roman Bozhenko on 16.02.2022.
//

import XCTest
import EssentialFeed

extension XCTestCase {
    var anyURL: URL { URL(string: "https://any-url.com")! }
    
    func trackForMemoryLeaks(_ object: AnyObject, file: StaticString = #filePath, line: UInt = #line) {
        addTeardownBlock { [weak object] in
            XCTAssertNil(object, file: file, line: line)
        }
    }
    
    func uniqueFeed() -> [FeedImage] {
        [FeedImage(id: UUID(), description: "any", location: "any", url: URL(string: "https://any-url.com")!)]
    }
    
    func anyNSError() -> NSError {
        NSError(domain: "any error", code: 0)
    }
    
    var anyData: Data { Data("any-data".utf8) }
}

private class DummyView: ResourceViewProtocol {
    func display(_ viewModel: Any) { }
}

var loadError: String {
    LoadResourcePresenter<Any, DummyView>.loadError
}

var feedTitle: String {
    FeedPresenter.title
}

var commentsTitle: String {
    ImageCommentsPresenter.title
}
