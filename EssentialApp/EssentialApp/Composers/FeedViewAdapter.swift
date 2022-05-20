//
//  FeedViewAdapter.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 02.01.2022.
//

import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewAdapter: ResourceViewProtocol {
    private weak var controller: FeedViewController?
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    
    
    init(controller: FeedViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: EssentialFeed.FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            let adapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>(loader: { [loader] in
                loader(model.url)
            })
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter<FeedImageCellController, UIImage>.map(model),
                delegate: adapter)
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: { data in
                    guard let image = UIImage(data: data) else {
                        throw InvalidImageData()
                    }
                    
                    return image
                })
            
            return view
        })
    }
}

private struct InvalidImageData: Error { }
