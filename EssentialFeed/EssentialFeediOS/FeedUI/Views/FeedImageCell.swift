//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 12.12.2021.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    @IBOutlet public var locationContainer: UIView!
    @IBOutlet public var locationLabel: UILabel!
    @IBOutlet public var descriptionLabel: UILabel!
    @IBOutlet public var feedImageContainer: UIView!
    @IBOutlet public var feedImageView: UIImageView!
    @IBOutlet public var feedImageRetryButton: UIButton!
    
    var onRetry: (() -> Void)?
    
    @IBAction private func didTapRetryButton() {
        onRetry?()
    }
}
