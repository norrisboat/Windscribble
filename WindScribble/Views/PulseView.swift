//
//  PulseView.swift
//  WindScribble
//
//  Created by Norris Aboagye Boateng on 19/09/2021.
//

import UIKit

class PulseView: UIView {
    
    @IBOutlet weak var ring1: UIView!
    @IBOutlet weak var ring2: UIView!
    @IBOutlet weak var ring3: UIView!
    @IBOutlet weak var powerImageView: UIImageView!
    @IBOutlet var contentView: UIView!
    
    private var isConnected = false
    private var timer: Timer? = nil
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        Bundle.main.loadNibNamed("PulseView", owner: self, options: nil)
        contentView.fixInView(self)
        ring1.makeCircular()
        ring2.makeCircular()
        ring3.makeCircular()
        ring1.backgroundColor = .inActiveColor
        ring2.backgroundColor = .lighterInActiveColor
        ring3.backgroundColor = .lightInActiveColor
    }
    
    func bouncyAnimation() {
        bounce()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: true) { [weak self] timer in
            self?.bounce()
        }
    }
    
    private func bounce() {
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: [.curveEaseInOut], animations: { [weak self] in
            self?.ring3.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: [.curveEaseInOut], animations: { [weak self] in
                self?.ring3.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { _ in
            }
        }
        
        UIView.animate(withDuration: 0.7, delay: 0.1, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: [.curveEaseInOut], animations: { [weak self] in
            self?.ring2.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        }) { _ in
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 5, options: [.curveEaseInOut], animations: { [weak self] in
                self?.ring2.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }) { _ in
            }
        }
    }
    
    func connectedAnimation() {
        UIView.transition(with: ring1, duration: 0.6, options: .transitionCrossDissolve, animations: { [weak self] in
            self?.ring1.backgroundColor = .primaryColor
            self?.powerImageView.tintColor = .primaryColor
            self?.timer?.invalidate()
        })
    }
    
    func disconnected() {
        self.ring1.layer.removeAllAnimations()
        self.ring2.layer.removeAllAnimations()
        self.ring3.layer.removeAllAnimations()
        self.ring1.backgroundColor = .inActiveColor
        self.powerImageView.tintColor = .inActiveColor
        self.timer?.invalidate()
    }
}
