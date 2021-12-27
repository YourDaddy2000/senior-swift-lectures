//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 14.12.2021.
//

import UIKit

protocol FeedRefreshViewControllerDelegate {
    func didRequestFeedRefresh()
}

final class FeedRefreshViewController: NSObject, FeedLoadingViewProtocol {
    private(set) lazy var view = loadView()
    
    private let delegate: FeedRefreshViewControllerDelegate

    init(delegate: FeedRefreshViewControllerDelegate) {
        self.delegate = delegate
    }
    
    private func loadView() -> UIRefreshControl {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return control
    }
    
    @objc func refresh() {
        delegate.didRequestFeedRefresh()
    }
    
    func display(viewModel: FeedLoadingViewModel) {
        viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
    }
}
