//
//  FeedImageCellController.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 14.12.2021.
//

import UIKit
import EssentialFeed

public protocol FeedImageCellControllerDelegate {
    func didRequestImage()
    func didCancelImageRequest()
}

public final class FeedImageCellController: FeedImageViewProtocol {
    private let delegate: FeedImageCellControllerDelegate
    private var cell: FeedImageCell?
    
    public init(delegate: FeedImageCellControllerDelegate) {
        self.delegate = delegate
    }
    
    func view(with tableView: UITableView) -> UITableViewCell {
        cell = tableView.dequeueReusableCell()
        delegate.didRequestImage()
        return cell!
    }
    
    func preload() {
        delegate.didRequestImage()
    }
    
    func cancelLoad() {
        delegate.didCancelImageRequest()
        releaseCellFromMemoryForReuse()
    }
    
    public func display(_ model: FeedImageViewModel<UIImage>) {
        cell?.locationContainer.isHidden = !model.hasLocation
        cell?.locationLabel.text = model.location
        cell?.descriptionLabel.text = model.description
        cell?.onRetry = delegate.didRequestImage
        cell?.feedImageView.setImageAnimated(model.image)
        cell?.feedImageContainer.isShimmering = model.isLoading
        cell?.feedImageRetryButton.isHidden = !model.shouldRetry
    }
    
    private func releaseCellFromMemoryForReuse() {
        cell = nil
    }
}
