//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 14.12.2021.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingViewProtocol {
    private(set) lazy var view = loadView()
    
    private let loadFeed: () -> Void

    init(loadFeed: @escaping () -> Void) {
        self.loadFeed = loadFeed
    }
    
    private func loadView() -> UIRefreshControl {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return control
    }
    
    @objc func refresh() {
        loadFeed()
    }
    
    func display(viewModel: FeedLoadingViewModel) {
        viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
    }
}
