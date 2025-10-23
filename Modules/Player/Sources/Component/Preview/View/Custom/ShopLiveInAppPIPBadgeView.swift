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
    
    private let imageCache = URLCache(
        memoryCapacity: 20 * 1024 * 1024,
        diskCapacity: 100 * 1024 * 1024,
        diskPath: "shoplive.pip.badge.imageCache"
    )
    
    private var imageUrlSession: URLSession = .init(configuration: .default)
    
    private var badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()
    
    private var imageAspectRatioConstraint: NSLayoutConstraint?
    private var currentUseCloseButton: Bool = false
    private var currentHorizontalAlignment: InAppPipDisplayHorizontalAlignment = .CENTER
    private var currentVerticalAlignment: InAppPipDisplayVerticalAlignment = .TOP
    private var horizontalConstraints: [NSLayoutConstraint] = []
    
    enum Action {
        case setBadge(String?)
        case setAlignment(useCloseButton: Bool, horizontal: InAppPipDisplayHorizontalAlignment, vertical: InAppPipDisplayVerticalAlignment)
        case hiddenBadge(Bool)
    }
    
    enum Result { }
    
    var resultHandler: ((Result) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
        setCache()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func action(_ action: Action) {
        switch action {
        case let .setBadge(url):
            onSetBadge(url)
        case let .setAlignment(useCloseButton, horizontal, vertical):
            onSetAlignment(useCloseButton: useCloseButton, horizontal, vertical)
        case let .hiddenBadge(isHidden):
            self.isHidden = isHidden
        }
    }
    
    private func onSetBadge(_ url: String?) {
        guard let url else { return }
        loadImage(from: url) { [weak self] image in
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
        
        onSetAlignment(useCloseButton: currentUseCloseButton, currentHorizontalAlignment, currentVerticalAlignment)
    }
    
    private func onSetAlignment(useCloseButton: Bool, _ horizontal: InAppPipDisplayHorizontalAlignment, _ vertical: InAppPipDisplayVerticalAlignment) {
        
        currentUseCloseButton = useCloseButton
        currentHorizontalAlignment = horizontal
        currentVerticalAlignment = vertical
        
        
        NSLayoutConstraint.deactivate(horizontalConstraints)
        horizontalConstraints.removeAll()
        switch horizontal {
        case .LEFT:
            
            var constant: CGFloat = 0
            
            // MARK: X 버튼 유 & vertical Alignment 가 TOP 일 경우 leading padding을 X 버튼 크기 만큼 주어야 함
            if useCloseButton && vertical == .TOP {
                constant = 26
            }
            
            horizontalConstraints = [
                badgeImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: constant),
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
        
        onSetAlignment(useCloseButton: currentUseCloseButton, currentHorizontalAlignment, currentVerticalAlignment)
    }
    
    private func setCache() {
        let config = URLSessionConfiguration.default
        config.urlCache = imageCache
        config.requestCachePolicy = .returnCacheDataElseLoad
        
        let session = URLSession(configuration: config)
        
        imageUrlSession = session
    }
    
    func loadImage(from urlString: String, completion: ((UIImage?) -> Void)? = nil) {
        guard let url = URL(string: urlString) else {
            completion?(nil)
            return
        }
        
        let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30.0)
        imageUrlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil,
                  let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    completion?(nil)
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.badgeImageView.image = image
                completion?(image)
            }
        }.resume()
    }
}
