//
//  WeakRefVirtualProxy.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 02.01.2022.
//

import UIKit
import EssentialFeed

final class WeakRefVirtualProxy<T: AnyObject> {
    private weak var object: T?
    
    internal init(_ object: T) {
        self.object = object
    }
}

extension WeakRefVirtualProxy: LoadingViewProtocol where T: LoadingViewProtocol {
    func display(_ viewModel: FeedLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: FeedImageViewProtocol where T: FeedImageViewProtocol, T.Image == UIImage {
    func display(_ model: FeedImageViewModel<UIImage>) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: FeedErrorViewProtocol where T: FeedErrorViewProtocol {
    func display(_ viewModel: FeedErrorViewModel) {
        object?.display(viewModel)
    }
}
