//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Roman Bozhenko on 05.12.2021.
//

import XCTest

final class FeedViewController: UIViewController {
    private var loader: FeedViewControllerTests.LoaderSpy?
    
    convenience init(loader: FeedViewControllerTests.LoaderSpy) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load()
    }
}

class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let loader = LoaderSpy()
        _ = FeedViewController(loader: loader)
        XCTAssertEqual(loader.loadCounts, 0)
    }
    
    func test_viewDidLoad_LoadsFeed() {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCounts, 1)
    }
    
    //MARK: - Helpers
    class LoaderSpy {
        private(set) var loadCounts: Int = 0
        
        func load() {
            loadCounts += 1
        }
    }
}
