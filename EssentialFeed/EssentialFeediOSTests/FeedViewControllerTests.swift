//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Roman Bozhenko on 05.12.2021.
//

import XCTest

final class FeedViewController {
    init(loader: FeedViewControllerTests.LoaderSpy) {
        
    }
}

class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        XCTAssertEqual(loader.loadCounts, 0)
    }
    
    //MARK: - Helpers
    class LoaderSpy {
        private(set) var loadCounts: Int = 0
    }

}
