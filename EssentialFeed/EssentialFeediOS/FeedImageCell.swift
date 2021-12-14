//
//  FeedImageCell.swift
//  EssentialFeediOS
//
//  Created by Roman Bozhenko on 12.12.2021.
//

import UIKit

public final class FeedImageCell: UITableViewCell {
    public let locationContainer = UIView()
    public let locationLabel = UILabel()
    public let descriptionLabel = UILabel()
    public let feedImageContainer = UIView()
    public let feedImageView = UIImageView()
    private(set) public lazy var feedImageRetryButton: UIButton = {
        let b = UIButton()
        b.addTarget(self, action: #selector(didTapRetryButton), for: .touchUpInside)
        return b
    }()
    
    var onRetry: (() -> Void)?
    
    @objc private func didTapRetryButton() {
        onRetry?()
    }
}
