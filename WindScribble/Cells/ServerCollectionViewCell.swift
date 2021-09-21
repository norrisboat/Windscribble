//
//  ServerCollectionViewCell.swift
//  WindScribble
//
//  Created by Norris Aboagye Boateng on 19/09/2021.
//

import UIKit
import Combine

class ServerCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var locationFlag: UIImageView!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var locationsLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    private var cancellables = Set<AnyCancellable>()
    @IBOutlet weak var container: UIView!
    
    func setupServerLocation(serverLocation: ServerLocation) {
        locationLabel.text = serverLocation.name
        let numberOfLocations = serverLocation.nodes?.count ?? 0
        if numberOfLocations == 1 {
            locationsLabel.text = "\(numberOfLocations) Location"
        } else {
            locationsLabel.text = "\(numberOfLocations) Locations"
        }
        locationFlag.makeCircular()
        locationFlag.clipsToBounds = true
        self.contentView.layer.cornerRadius = 10
        serverLocation.countryCode?.loadFlagImage().sink { [unowned self] image in self.locationFlag.image = image }.store(in: &cancellables)
    }
    
    func toggle(expanded: Bool) {
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            if expanded {
                self?.arrowImageView.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
            } else {
                self?.arrowImageView.transform = CGAffineTransform.identity
            }
        })
    }
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attrs = super.preferredLayoutAttributesFitting(layoutAttributes)
        attrs.bounds.size.height = 70
        return attrs
    }
    
}
