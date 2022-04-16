//
//  FeedImageDataLoaderPresentationAdapter.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 02.01.2022.
//

import EssentialFeed
import EssentialFeediOS

final class FeedImageDataLoaderPresentationAdapter<View: FeedImageViewProtocol, Image>: FeedImageCellControllerDelegate where View.Image == Image {
    private let model: FeedImage
    private let imageLoader: FeedImageDataLoader
    private var task: FeedImageDataLoaderTask?
    
    var presenter: FeedImagePresenter<View, Image>?
    
    internal init(model: FeedImage, imageLoader: FeedImageDataLoader) {
        self.model = model
        self.imageLoader = imageLoader
    }
    
    func didRequestImage() {
        presenter?.didStartLoadingData(for: model)
        
        let model = self.model
        task = imageLoader.loadImageData(from: model.url, completion: { [weak presenter] result in
            switch result {
            case .success(let data):
                presenter?.didFinishLoadingImageData(with: data, for: model)
            case .failure(let error):
                presenter?.didFinishLoadingImageData(with: error, for: model)
            }
        })
    }
    
    func didCancelImageRequest() {
        task?.cancel()
    }
}
