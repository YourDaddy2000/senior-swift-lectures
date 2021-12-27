//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 14.12.2021.
//

import UIKit

final class FeedRefreshViewController: NSObject, FeedLoadingViewProtocol {
    private(set) lazy var view = loadView()
    
    private let presenter: FeedPresenter

    init(presenter: FeedPresenter) {
        self.presenter = presenter
    }
    
    private func loadView() -> UIRefreshControl {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        return control
    }
    
    @objc func refresh() {
        presenter.refresh()
    }
    
    func display(isLoading: Bool) {
        isLoading ? view.beginRefreshing() : view.endRefreshing()
    }
}
