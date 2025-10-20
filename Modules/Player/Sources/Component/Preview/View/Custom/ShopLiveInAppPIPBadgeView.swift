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
    
    private var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fill
        stackView.alignment = .center
        return stackView
    }()
    
    private var leadingSpacingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .horizontal) // 낮은 우선순위
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    private var trailingSpacingView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setContentHuggingPriority(.defaultLow, for: .horizontal) // 낮은 우선순위
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return view
    }()
    
    private var badgeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.required, for: .horizontal) // 높은 우선순위
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        return imageView
    }()
    
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
            onSetAlignment(alignment)
        case let .hiddenBadge(isHidden):
            self.isHidden = isHidden
        }
    }
    
    private func onSetBadge(_ url: URL?) {
        // URL에서 이미지 로드
        if let image = UIImage(named: "SDK.Preview.ImageBadge") {
            badgeImageView.image = image
        }
    }
    
    private func onSetAlignment(_ alignment: InAppPipDisplayHorizontalAlignment) {
        // 기존 arrangedSubviews 제거
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // 기존 제약 제거
        NSLayoutConstraint.deactivate(leadingSpacingView.constraints)
        NSLayoutConstraint.deactivate(trailingSpacingView.constraints)
        
        switch alignment {
        case .LEFT:
            // [이미지][spacer]
            stackView.addArrangedSubview(badgeImageView)
            stackView.addArrangedSubview(trailingSpacingView)
            
            // spacer가 최소 너비 1 이상
            NSLayoutConstraint.activate([
                trailingSpacingView.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
            ])
            
        case .CENTER:
            // [spacer][이미지][spacer]
            stackView.addArrangedSubview(leadingSpacingView)
            stackView.addArrangedSubview(badgeImageView)
            stackView.addArrangedSubview(trailingSpacingView)
            
            // 양쪽 spacer 동일한 너비
            NSLayoutConstraint.activate([
                leadingSpacingView.widthAnchor.constraint(equalTo: trailingSpacingView.widthAnchor),
                leadingSpacingView.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
            ])
            
        case .RIGHT:
            // [spacer][이미지]
            stackView.addArrangedSubview(leadingSpacingView)
            stackView.addArrangedSubview(badgeImageView)
            
            // spacer가 최소 너비 1 이상
            NSLayoutConstraint.activate([
                leadingSpacingView.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
            ])
        }
    }
    
    private func setLayout() {
        self.backgroundColor = .clear
        self.addSubview(stackView)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        // 초기 이미지 설정
        if let image = UIImage(named: "SDK.Preview.ImageBadge") {
            badgeImageView.image = image
        }
        
        // 기본 정렬은 RIGHT
        onSetAlignment(.RIGHT)
    }
}
