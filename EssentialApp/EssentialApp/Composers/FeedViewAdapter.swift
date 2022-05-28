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
    private weak var controller: ListViewController?
    private let loader: (URL) -> FeedImageDataLoader.Publisher
    
    
    init(controller: ListViewController, loader: @escaping (URL) -> FeedImageDataLoader.Publisher) {
        self.controller = controller
        self.loader = loader
    }
    
    func display(_ viewModel: EssentialFeed.FeedViewModel) {
        controller?.display(viewModel.feed.map { model in
            typealias ImageDataPresentationAdapter = LoadResourcePresentationAdapter<Data, WeakRefVirtualProxy<FeedImageCellController>>
            
            let adapter = ImageDataPresentationAdapter(loader: { [loader] in
                loader(model.url)
            })
            let view = FeedImageCellController(
                viewModel: FeedImagePresenter.map(model),
                delegate: adapter)
            
            adapter.presenter = LoadResourcePresenter(
                resourceView: WeakRefVirtualProxy(view),
                loadingView: WeakRefVirtualProxy(view),
                errorView: WeakRefVirtualProxy(view),
                mapper: UIImage.tryMake)
            
            return CellController(id: model, view)
        })
    }
}

extension UIImage {
    struct InvalidImageData: Error { }
    
    static func tryMake(data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else {
            throw InvalidImageData()
        }
        
        return image
    }
}
