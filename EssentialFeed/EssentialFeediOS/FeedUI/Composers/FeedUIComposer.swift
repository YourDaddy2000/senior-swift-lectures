//
//  FeedUIComposer.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 15.12.2021.
//
import EssentialFeed
import UIKit

public enum FeedUIComposer {
    public static func composeFeedViewController(feedLoader: FeedLoader, imageLoader: FeedImageDataLoader) -> FeedViewController {
        let presenter = FeedPresenter(feedLoader: feedLoader)
        let refreshController = FeedRefreshViewController(presenter: presenter)
        let feedController = FeedViewController(refreshViewController: refreshController)
        presenter.loadingView = WeakRefVirtualProxy(refreshController)
        presenter.feedView = FeedViewAdapter(controller: feedController, loader: imageLoader)
        
        return feedController
    }
}

private final class FeedViewAdapter: FeedViewProtocol {
    private weak var controller: FeedViewController?
    private let loader: FeedImageDataLoader
    
    
    init(controller: FeedViewController, loader: FeedImageDataLoader) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(viewModel: FeedViewModel) {
        controller?.tableModel = viewModel.feed.map { model in
            FeedImageCellController(
                viewModel: FeedImageViewModel(
                    model: model,
                    imageLoader: loader,
                    imageTransformer: UIImage.init
                )
            )
        }
    }
}

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    internal init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: FeedLoadingViewProtocol where T: FeedLoadingViewProtocol {
    func display(viewModel: FeedLoadingViewModel) {
        object?.display(viewModel: viewModel)
    }
}
