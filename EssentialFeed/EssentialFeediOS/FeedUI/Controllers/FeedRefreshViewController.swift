//
//  FeedRefreshViewController.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 14.12.2021.
//

import UIKit

final class FeedRefreshViewController: NSObject {
    private(set) lazy var view = binded(UIRefreshControl())
    
    private let viewModel: FeedViewModel

    init(viewModel: FeedViewModel) {
        self.viewModel = viewModel
    }
    
    private func binded(_ control: UIRefreshControl) -> UIRefreshControl {
        control.addTarget(self, action: #selector(refresh), for: .valueChanged)
        
        viewModel.onLoadingStateChange = { [weak control] isLoading in
            isLoading ? control?.beginRefreshing() : control?.endRefreshing()
        }
        
        return control
    }
    
    @objc func refresh() {
        viewModel.refresh()
    }
}
