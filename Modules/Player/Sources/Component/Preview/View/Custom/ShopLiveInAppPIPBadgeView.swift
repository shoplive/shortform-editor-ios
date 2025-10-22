//
//  ShopLiveInAppPIPBadgeView.swift
//  ShopLiveSDK
//
//  Created by Tabber on 10/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopliveSDKCommon

final class ShopLiveInAppPIPBadgeView: UIView, SLReactor {
    
    private var badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()
    
    private var imageAspectRatioConstraint: NSLayoutConstraint?
    private var currentAlignment: InAppPipDisplayHorizontalAlignment = .CENTER
    private var horizontalConstraints: [NSLayoutConstraint] = []
    
    enum Action {
        case setBadge(URL?)
        case setAlignment(InAppPipDisplayHorizontalAlignment)
        case hiddenBadge(Bool)
    }
    
    enum Result { }
    
    var resultHandler: ((Result) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setBadge(url):
            onSetBadge(url)
        case let .setAlignment(alignment):
            currentAlignment = alignment
            onSetAlignment(alignment)
        case let .hiddenBadge(isHidden):
            self.isHidden = isHidden
        }
    }
    
    private func onSetBadge(_ url: URL?) {
        badgeImageView.loadImage(from: url?.absoluteString ?? "") { [weak self] image in
            guard let self = self, let image = image else { return }
            self.updateImageViewAspectRatio(for: image)
        }
    }
    
    private func updateImageViewAspectRatio(for image: UIImage) {
        if let existingConstraint = imageAspectRatioConstraint {
            badgeImageView.removeConstraint(existingConstraint)
        }
        
        let aspectRatio = image.size.width / image.size.height
        
        imageAspectRatioConstraint = badgeImageView.widthAnchor.constraint(
            equalTo: badgeImageView.heightAnchor,
            multiplier: aspectRatio
        )
        imageAspectRatioConstraint?.isActive = true
        
        onSetAlignment(currentAlignment)
    }
    
    private func onSetAlignment(_ alignment: InAppPipDisplayHorizontalAlignment) {
        NSLayoutConstraint.deactivate(horizontalConstraints)
        horizontalConstraints.removeAll()
        switch alignment {
        case .LEFT:
            horizontalConstraints = [
                badgeImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                badgeImageView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor)
            ]
            
        case .CENTER:
            horizontalConstraints = [
                badgeImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                badgeImageView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor),
                badgeImageView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor)
            ]
            
        case .RIGHT:
            horizontalConstraints = [
                badgeImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                badgeImageView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor)
            ]
        }
        
        NSLayoutConstraint.activate(horizontalConstraints)
        
        self.setNeedsLayout()
        self.layoutIfNeeded()
    }
    
    private func setLayout() {
        self.backgroundColor = .clear
        self.addSubview(badgeImageView)
        
        badgeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            badgeImageView.topAnchor.constraint(equalTo: self.topAnchor),
            badgeImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        onSetAlignment(currentAlignment)
    }
}

extension UIImageView {
    func loadImage(from urlString: String, completion: ((UIImage?) -> Void)? = nil) {
        guard let url = URL(string: urlString) else {
            completion?(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion?(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.image = image
                completion?(image)
            }
        }.resume()
    }
}
