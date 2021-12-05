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
    @IBOutlet private weak var feedImageContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedImageView.alpha = 0
        feedImageContainer.startShimmering()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        feedImageView.alpha = 0
        feedImageContainer.startShimmering()
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
        
        UIView.animate(withDuration: 0.3, delay: 0.3, animations: {
            self.feedImageView.alpha = 1
        }, completion: { [weak self] _ in
            self?.feedImageContainer.stopShimmering()
        })
    }
}

private extension UIView {
    private var shimmerAnimationKey: String {
        return "shimmer"
    }
    
    func startShimmering() {
        let white = UIColor.white.cgColor
        let alpha = UIColor.white.withAlphaComponent(0.7).cgColor
        let width = bounds.width
        let height = bounds.height
        
        let gradient = CAGradientLayer()
        gradient.colors = [alpha, white, alpha]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.4)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.6)
        gradient.locations = [0.4, 0.5, 0.6]
        gradient.frame = CGRect(x: -width, y: 0, width: width*3, height: height)
        layer.mask = gradient
        
        let animation = CABasicAnimation(keyPath: #keyPath(CAGradientLayer.locations))
        animation.fromValue = [0.0, 0.1, 0.2]
        animation.toValue = [0.8, 0.9, 1.0]
        animation.duration = 1
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: shimmerAnimationKey)
    }
    
    func stopShimmering() {
        layer.mask = nil
    }
}
