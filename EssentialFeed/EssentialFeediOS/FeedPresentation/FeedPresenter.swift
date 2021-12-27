//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 20.12.2021.
//

import EssentialFeed

struct FeedLoadingViewModel {
    let isLoading: Bool
}

protocol FeedLoadingViewProtocol {
    func display(viewModel: FeedLoadingViewModel)
}

struct FeedViewModel {
    let feed: [FeedImage]
}

protocol FeedViewProtocol {
    func display(viewModel: FeedViewModel)
}

final class FeedPresenter {
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedViewProtocol?
    var loadingView: FeedLoadingViewProtocol?
    
    func loadFeed() {
        loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: true))
        
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(viewModel: FeedViewModel(feed: feed))
            }
            
            self?.loadingView?.display(viewModel: FeedLoadingViewModel(isLoading: false))
        }
    }
}
