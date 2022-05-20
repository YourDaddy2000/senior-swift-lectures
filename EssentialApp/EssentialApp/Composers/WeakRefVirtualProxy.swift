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

extension WeakRefVirtualProxy: ResourceLoadingViewProtocol where T: ResourceLoadingViewProtocol {
    func display(_ viewModel: ResourceLoadingViewModel) {
        object?.display(viewModel)
    }
}

extension WeakRefVirtualProxy: ResourceViewProtocol where T: ResourceViewProtocol, T.ResourceViewModel == UIImage {
    func display(_ model: UIImage) {
        object?.display(model)
    }
}

extension WeakRefVirtualProxy: ResourceErrorViewProtocol where T: ResourceErrorViewProtocol {
    func display(_ viewModel: EssentialFeed.ResourceErrorViewModel) {
        object?.display(viewModel)
    }
}
