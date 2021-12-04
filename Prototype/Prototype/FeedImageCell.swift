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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedImageView.alpha = 0
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        feedImageView.alpha = 0
    }
    
    func configure(with model: FeedImageViewModel) {
        locationContainer.isHidden = model.location == nil
        locationLabel.text = model.location
        
        descriptionLabel.isHidden = model.description == nil
        descriptionLabel.text = model.description
        
        fadeIn(imageName: model.imageName)
    }
    
    private func fadeIn(imageName name: String) {
        feedImageView.image = UIImage(named: name)
        
        UIView.animate(withDuration: 0.3, delay: 0.3) {
            self.feedImageView.alpha = 1
        }
    }
}
