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
        return imageView
    }()
    
    enum Action {
        case setBadge(URL)
        case hiddenBadge(Bool)
    }
    
    enum Result { }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var resultHandler: ((Result) -> ())?
    
    func action(_ action: Action) {
        switch action {
        case let .setBadge(url):
            onSetBadge(url)
        case let .hiddenBadge(isHidden):
            self.isHidden = isHidden
        }
    }
    
    private func onSetBadge(_ url: URL) {
        // url 세팅 후 진행
    }
    
    
    private func setLayout() {
        self.addSubview(badgeImageView)
        
        badgeImageView.translatesAutoresizingMaskIntoConstraints = false
        
        badgeImageView.image = UIImage(named: "SDK.Preview.ImageBadge")
        
        NSLayoutConstraint.activate([
            badgeImageView.topAnchor.constraint(equalTo: self.topAnchor),
            badgeImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            badgeImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            badgeImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
