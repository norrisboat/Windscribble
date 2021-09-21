//
//  UIViewExtensions.swift
//  WindScribble
//
//  Created by Norris Aboagye Boateng on 19/09/2021.
//


import UIKit
import Combine

enum Cell : String {
    case serverLocationCell = "ServerCollectionViewCell"
}

extension UINib {
    
    convenience init(cell: Cell) {
        self.init(nibName: cell.rawValue, bundle: nil)
    }
    
}

extension UICollectionView {
    
    func register(cell: Cell, cellIdentifier: String) {
        let nibName = UINib(cell: cell)
        self.register(nibName, forCellWithReuseIdentifier: cellIdentifier)
    }
    
}

extension UIView {
    
    func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false;
        self.frame = container.frame;
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
    }
    
    func makeCircular() {
        self.layer.cornerRadius = self.frame.height / 2
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
    
    func roundTopCorners(radius: CGFloat = 10) {
        
        self.clipsToBounds = true
        self.layer.cornerRadius = radius
        if #available(iOS 11.0, *) {
            self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        } else {
            self.roundCorners(corners: [.topLeft, .topRight], radius: radius)
        }
    }
    
    func tapBounceAnimation() {
      isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       options: .curveLinear,
                       animations: { [weak self] in
                            self?.transform = CGAffineTransform.init(scaleX: 0.95, y: 0.95)
        }) {  (done) in
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           options: .curveLinear,
                           animations: { [weak self] in
                                self?.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { [weak self] (_) in
                self?.isUserInteractionEnabled = true
            }
        }
    }
    
}

extension UILabel {
    
    func makePill() {
        self.layer.cornerRadius = 20
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }
    
}

extension String {
    
    func toURL() -> URL { return URL(string: self.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)! }
    
    func loadFlagImage() -> AnyPublisher<UIImage?, Never> {
        return Just(self)
            .flatMap({ poster -> AnyPublisher<UIImage?, Never> in
                return ImageLoader.shared.loadImage(from: self.getFlagURL().toURL())
        })
            .eraseToAnyPublisher()
    }
    
    func getFlagURL() -> String {
        return "https://www.countryflags.io/\(self.lowercased())/flat/64.png"
    }
}

extension UIViewController {
    
    func showAlert(title: String, message: String,actionText: String = "OK") {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction.init(title: actionText, style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
