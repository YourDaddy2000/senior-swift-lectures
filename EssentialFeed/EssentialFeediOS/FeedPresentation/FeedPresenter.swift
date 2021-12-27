//
//  FeedPresenter.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 20.12.2021.
//

import EssentialFeed

protocol FeedLoadingViewProtocol {
    func display(isLoading: Bool)
}

protocol FeedViewProtocol {
    func display(feed: [FeedImage])
}

final class FeedPresenter {
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var feedView: FeedViewProtocol?
    var loadingView: FeedLoadingViewProtocol?
    
    func refresh() {
        loadingView?.display(isLoading: true)
        
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.feedView?.display(feed: feed)
            }
            
            self?.loadingView?.display(isLoading: false)
        }
    }
}
