//
//  FeedViewControllerTests.swift
//  EssentialFeediOSTests
//
//  Created by Roman Bozhenko on 05.12.2021.
//

import XCTest
import UIKit
import EssentialFeed

final class FeedViewController: UIViewController {
    private var loader: FeedLoader?
    
    convenience init(loader: FeedLoader) {
        self.init()
        self.loader = loader
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader?.load { _ in }
    }
}

class FeedViewControllerTests: XCTestCase {

    func test_init_doesNotLoadFeed() {
        let (_, loader) = makeSUT()
        XCTAssertEqual(loader.loadCounts, 0)
    }
    
    func test_viewDidLoad_LoadsFeed() {
        let (sut, loader) = makeSUT()
        
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(loader.loadCounts, 1)
    }
    
    //MARK: - Helpers
    private func makeSUT() -> (FeedViewController, LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        trackForMemoryLeaks(loader)
        trackForMemoryLeaks(sut)
        return (sut, loader)
    }
    
    class LoaderSpy: FeedLoader {
        private(set) var loadCounts: Int = 0
        
        func load(completion: @escaping (FeedLoader.Result) -> Void) {
            loadCounts += 1
        }
    }
}
