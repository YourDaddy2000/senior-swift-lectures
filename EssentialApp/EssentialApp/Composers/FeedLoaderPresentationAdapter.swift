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
    private let feedLoader: () -> AnyPublisher<[FeedImage], Error>
    private var cancellable: Cancellable?
    var presenter: LoadResourcePresenter<[FeedImage], FeedViewAdapter>?
    
    internal init(feedLoader: @escaping () -> AnyPublisher<[FeedImage], Error>) {
        self.feedLoader = feedLoader
    }
    
    func didRequestFeedRefresh() {
        presenter?.didStartLoading()
        
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
