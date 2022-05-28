//
//  ListSnapshotsTests.swift
//  EssentialFeediOSTests
//
//  Created by Roman Bozhenko on 27.05.2022.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ListSnapshotsTests: XCTestCase {

    func test_EmptyFeed() {
        let sut = makeSUT()
        
        sut.display(emptyFeed)
        
        assert(snapshot: sut.shapshot(for: .iPhone8(style: .light)), named: "EMPTY_FEED_light")
        assert(snapshot: sut.shapshot(for: .iPhone8(style: .dark)), named: "EMPTY_FEED_dark")
    }
    
    func test_feedWithErrorMessage() {
        let sut = makeSUT()
        
        sut.display(.error(message: "This is\na multi-line\nerror message"))
        
        assert(snapshot: sut.shapshot(for: .iPhone8(style: .light)), named: "FEED_WITH_ERROR_light")
        assert(snapshot: sut.shapshot(for: .iPhone8(style: .dark)), named: "FEED_WITH_ERROR_dark")
        assert(snapshot: sut.shapshot(for: .iPhone8(style: .light, contentSize: .extraExtraExtraLarge)), named: "FEED_WITH_ERROR_light_extraExtraExtraLarge")
    }
    
    //MARK: - Helpers
    
    private var emptyFeed: [CellController] { [] }

    private func makeSUT() -> ListViewController {
        let controller = ListViewController()
        controller.loadViewIfNeeded()
        controller.tableView.separatorStyle = .none
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
}
