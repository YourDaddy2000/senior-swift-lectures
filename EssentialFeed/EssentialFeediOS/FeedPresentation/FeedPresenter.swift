//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 20.12.2021.
//

import Foundation
import EssentialFeed

protocol FeedErrorViewProtocol {
    func display(_ viewModel: FeedErrorViewModel)
}

protocol FeedLoadingViewProtocol {
    func display(viewModel: FeedLoadingViewModel)
}

protocol FeedViewProtocol {
    func display(viewModel: FeedViewModel)
}

final class FeedPresenter {
    var feedView: FeedViewProtocol
    var loadingView: FeedLoadingViewProtocol
    var errorView: FeedErrorViewProtocol
    
    internal init(feedView: FeedViewProtocol, loadingView: FeedLoadingViewProtocol, errorView: FeedErrorViewProtocol) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    static var title: String {
        NSLocalizedString(
            "feed_view_title",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for Feed View")
    }
    
    private var feedLoadError: String {
        NSLocalizedString(
            "FEED_VIEW_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: Self.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    func didStartLoadingFeed() {
        errorView.display(FeedErrorViewModel(message: nil))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: true))
    }
    
    func didEndLoadingFeed(with feed: [FeedImage]) {
        feedView.display(viewModel: FeedViewModel(feed: feed))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
    
    func didEndLoadingFeed(with error: Error) {
        errorView.display(FeedErrorViewModel(message: feedLoadError))
        loadingView.display(viewModel: FeedLoadingViewModel(isLoading: false))
    }
}
