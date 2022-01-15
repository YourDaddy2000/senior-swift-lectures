//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 15.01.2022.
//

protocol FeedViewProtocol {
    func display(_ viewModel: FeedViewModel)
}

protocol LoadingViewProtocol {
    func display(_ viewModel: FeedLoadingViewModel)
}

protocol FeedErrorViewProtocol {
    func display(_ viewModel: FeedErrorViewModel)
}

final class FeedPresenter {
    private let errorView: FeedErrorViewProtocol
    private let loadingView: LoadingViewProtocol
    private let feedView: FeedViewProtocol
    
    init(feedView: FeedViewProtocol, loadingView: LoadingViewProtocol, errorView: FeedErrorViewProtocol) {
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
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    func didFinishLoading(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    func didFinishLoading(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
