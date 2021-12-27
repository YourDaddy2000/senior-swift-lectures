//
//  FeedViewModel.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 17.12.2021.
//

import EssentialFeed

typealias Observer<T> = (T) -> Void

final class FeedViewModel {
    private let feedLoader: FeedLoader
    
    init(feedLoader: FeedLoader) {
        self.feedLoader = feedLoader
    }
    
    var onLoadingStateChange: Observer<Bool>?
    var onRefresh: Observer<[FeedImage]>?
    
    func refresh() {
        onLoadingStateChange?(true)
        
        feedLoader.load { [weak self] result in
            if let feed = try? result.get() {
                self?.onRefresh?(feed)
            }
            
            self?.onLoadingStateChange?(false)
        }
    }
}
