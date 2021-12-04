//
//  FeedImageCell.swift
//  Prototype
//
//  Created by Roman Bozhenko on 04.12.2021.
//

import UIKit

class FeedImageCell: UITableViewCell {
    @IBOutlet private weak var locationContainer: UIView!
    @IBOutlet private weak var locationLabel: UILabel!
    @IBOutlet private weak var feedImageView: UIImageView!
    @IBOutlet private weak var descriptionLabel: UILabel!
    
    func configure(with model: FeedImageViewModel) {
        locationContainer.isHidden = model.location == nil
        locationLabel.text = model.location
        
        feedImageView.image = UIImage(named: model.imageName)
        
        descriptionLabel.text = model.description
        descriptionLabel.isHidden = model.description == nil
    }
}
