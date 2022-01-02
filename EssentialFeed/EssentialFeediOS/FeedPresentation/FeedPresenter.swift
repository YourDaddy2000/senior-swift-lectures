//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 20.12.2021.
//

import Foundation
import EssentialFeed

protocol FeedLoadingViewProtocol {
    func display(viewModel: FeedLoadingViewModel)
}

protocol FeedViewProtocol {
    func display(viewModel: FeedViewModel)
}

final class FeedPresenter {
    var feedView: FeedViewProtocol
    var loadingView: FeedLoadingViewProtocol
    
    internal init(feedView: FeedViewProtocol, loadingView: FeedLoadingViewProtocol) {
        self.feedView = feedView
        self.loadingView = loadingView
    }
    
    static var title: String {
        NSLocalizedString(
            "feed_view_title",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for Feed View")
    }
    
    func didStartLoadingFeed() {
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    func didEndLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: FeedViewModel(feed: feed))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    func didEndLoadingFeed(with error: Error) {
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
