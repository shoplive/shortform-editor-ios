//
//  SlBlurLabel.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/16/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit


class SlBlurBGLabel : UIView {
    let normalblurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    lazy var blurEffectView = UIVisualEffectView(effect: normalblurEffect)
    
    private let stack = UIStackView()
    let label = UILabel()
    
    
    var _layoutMargin : UIEdgeInsets = .zero {
        didSet {
            stack.layoutMargins = _layoutMargin
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        blurEffectView.frame = self.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        blurEffectView.isUserInteractionEnabled = false
        self.backgroundColor = .clear
        setLayout()
        
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.sendSubviewToBack(blurEffectView)
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    
}
extension SlBlurBGLabel {
    private func setLayout() {
        self.addSubview(stack)
        stack.addArrangedSubview(label)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.isLayoutMarginsRelativeArrangement = true
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}

