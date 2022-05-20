//
//  LoadResourcePresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 02.01.2022.
//

import Combine
import EssentialFeed
import EssentialFeediOS

final class LoadResourcePresentationAdapter<Resource, View: ResourceViewProtocol> {
    private let loader: () -> AnyPublisher<Resource, Error>
    private var cancellable: Cancellable?
    var presenter: LoadResourcePresenter<Resource, View>?
    
    internal init(loader: @escaping () -> AnyPublisher<Resource, Error>) {
        self.loader = loader
    }
    
    func loadResource() {
        presenter?.didStartLoading()
        
        cancellable = loader().sink { [weak presenter] completion in
            switch completion {
            case .finished: break
            case .failure(let error):
                presenter?.didFinishLoading(with: error)
            }
        } receiveValue: { [weak presenter] resource in
            presenter?.didFinishLoading(with: resource)
        }
    }
}

extension LoadResourcePresentationAdapter: FeedViewControllerDelegate {
    func didRequestFeedRefresh() {
        loadResource()
    }
}

extension LoadResourcePresentationAdapter: FeedImageCellControllerDelegate {
    func didRequestImage() {
        loadResource()
    }
    
    func didCancelImageRequest() {
        cancellable?.cancel()
        cancellable = nil
    }
}
