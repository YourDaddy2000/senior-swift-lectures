//
//  FeedLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 02.01.2022.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class FeedLoaderPresentationAdapter: FeedViewControllerDelegate {
    private let feedLoader: () -> FeedLoader.Publisher
    private var cancellable: Cancellable?
    var presenter: FeedPresenter?
    
    internal init(feedLoader: @escaping () -> FeedLoader.Publisher) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoadingFeed()
        
        cancellable = feedLoader().sink { [weak presenter] completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                presenter?.didFinishLoading(with: error)
            }
        } receiveValue: { [weak presenter] feed in
            presenter?.didFinishLoading(with: feed)
        }
    }
}
