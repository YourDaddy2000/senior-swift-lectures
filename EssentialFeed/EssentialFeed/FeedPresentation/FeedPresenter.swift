//
//  FeedPresenter.swift
//  EssentialFeed
//
//  Created by Roman Bozhenko on 15.01.2022.
//

public protocol FeedViewProtocol {
    func display(_ viewModel: FeedViewModel)
}

public protocol LoadingViewProtocol {
    func display(_ viewModel: FeedLoadingViewModel)
}

public protocol FeedErrorViewProtocol {
    func display(_ viewModel: FeedErrorViewModel)
}

public final class FeedPresenter {
    private let errorView: FeedErrorViewProtocol
    private let loadingView: LoadingViewProtocol
    private let feedView: FeedViewProtocol
    
    public init(feedView: FeedViewProtocol, loadingView: LoadingViewProtocol, errorView: FeedErrorViewProtocol) {
        self.feedView = feedView
        self.loadingView = loadingView
        self.errorView = errorView
    }
    
    public static var title: String {
        NSLocalizedString(
            "feed_view_title",
            tableName: "Feed",
            bundle: Bundle(for: FeedPresenter.self),
            comment: "Title for Feed View")
    }
    
    private var feedLoadError: String {
        NSLocalizedString(
            "GENERIC_CONNECTION_ERROR",
            tableName: "Feed",
            bundle: Bundle(for: Self.self),
            comment: "Error message displayed when we can't load the image feed from the server")
    }
    
    public func didStartLoadingFeed() {
        errorView.display(.noError)
        loadingView.display(FeedLoadingViewModel(isLoading: true))
    }
    
    public func didFinishLoading(with feed: [FeedImage]) {
        feedView.display(FeedViewModel(feed: feed))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
    
    public func didFinishLoading(with error: Error) {
        errorView.display(.error(message: feedLoadError))
        loadingView.display(FeedLoadingViewModel(isLoading: false))
    }
}
