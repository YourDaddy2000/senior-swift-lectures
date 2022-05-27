//
//  ImageCommentsSnapshotTests.swift
//  EssentialFeediOSTests
//
//  Created by Roman Bozhenko on 27.05.2022.
//

import XCTest
import EssentialFeediOS
@testable import EssentialFeed

class ImageCommentsSnapshotTests: XCTestCase {

    func test_listWithComments() {
        let sut = makeSUT()
        
        sut.display(comments)
        
        assert(snapshot: sut.shapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_light")
        assert(snapshot: sut.shapshot(for: .iPhone8(style: .light)), named: "IMAGE_COMMENTS_dark")
    }

    //MARK: - Helpers
    
    private func makeSUT() -> ListViewController {
        let bundle = Bundle(for: ListViewController.self)
        let storyBoard = UIStoryboard(name: "ImageComments", bundle: bundle)
        let controller = storyBoard.instantiateInitialViewController() as! ListViewController
        controller.loadViewIfNeeded()
        controller.tableView.showsVerticalScrollIndicator = false
        controller.tableView.showsHorizontalScrollIndicator = false
        return controller
    }
    
    private var comments: [CellController] {
        return [
            ImageCommentCellController(
                model: .init(
                    message: "The East Side Gallery is an open-air gallery in Berlin. It consists of a series of murals painted directly on a 1,316 m long remnant of the Berlin Wall, located near the centre of Berlin, on Mühlenstraße in Friedrichshain-Kreuzberg. The gallery has official status as a Denkmal, or heritage-protected landmark.",
                    date: "1000 years ago",
                    username: "a long long long long username"
                )
            ),
            ImageCommentCellController(
                model: .init(
                    message: "East Side Gallery\nMemorial in Berlin, Germany",
                    date: "10 days ago",
                    username: "a username"
                )
            ),
            ImageCommentCellController(
                model: .init(
                    message: "nice",
                    date: "1 hour ago",
                    username: "a."
                )
            )
        ]
    }
}
