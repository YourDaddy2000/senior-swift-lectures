//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 20.12.2021.
//

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
