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
    @IBOutlet private(set) weak var view: UIRefreshControl!
    
    var delegate: FeedRefreshViewControllerDelegate?
    
    @IBAction func refresh() {
        delegate?.didRequestFeedRefresh()
    }
    
    func display(viewModel: FeedLoadingViewModel) {
        viewModel.isLoading ? view.beginRefreshing() : view.endRefreshing()
    }
}
