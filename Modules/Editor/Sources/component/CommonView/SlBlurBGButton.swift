//
//  SlBlurBGButton.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/8/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit

class SlBlurBGButton : UIButton {
    let normalblurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    let selectedBlurEffect = UIBlurEffect(style: .extraLight)
    lazy var blurEffectView = UIVisualEffectView(effect: normalblurEffect)
    
    private let stack = UIStackView()
    private let myimageView = UIImageView()
    
    
    var imageLayoutMargin : UIEdgeInsets = .zero {
        didSet {
            stack.layoutMargins = imageLayoutMargin
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.blurEffectView.effect = isSelected ? selectedBlurEffect : normalblurEffect
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
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        myimageView.image = image
    }
    
    override var imageView: UIImageView? {
        return self.myimageView
    }
    
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let touchrect = self.bounds
        
        if touchrect.contains(point) {
            return self
        }
        else {
            return nil
        }
    }
    
    
}
extension SlBlurBGButton {
    private func setLayout() {
        self.addSubview(stack)
        stack.addArrangedSubview(myimageView)
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
