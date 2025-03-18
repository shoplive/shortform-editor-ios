//
//  SlBlurBGButton.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/8/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon

class SlBlurBGButton : UIButton {
    let normalblurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
    let selectedBlurEffect = UIBlurEffect(style: .light)
    lazy var normalBlurEffectView = UIVisualEffectView(effect: normalblurEffect)
    lazy var selectedBlurEffectView = UIVisualEffectView(effect: selectedBlurEffect)
    
    private let stack = UIStackView()
    private let myimageView = UIImageView()
    let titleTextLabel : SLLabel = {
        let label = SLLabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    var imageLayoutMargin : UIEdgeInsets = .zero {
        didSet {
            stack.layoutMargins = imageLayoutMargin
        }
    }
    
    override var isSelected: Bool {
        didSet {
            self.normalBlurEffectView.isHidden = isSelected ? true : false
            self.selectedBlurEffectView.isHidden = isSelected ? false : true
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        normalBlurEffectView.frame = self.bounds
        normalBlurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(normalBlurEffectView)
        normalBlurEffectView.isUserInteractionEnabled = false
        
        selectedBlurEffectView.frame = self.bounds
        selectedBlurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(selectedBlurEffectView)
        selectedBlurEffectView.isUserInteractionEnabled = false
        
        self.backgroundColor = .clear
        setLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.sendSubviewToBack(normalBlurEffectView)
        self.sendSubviewToBack(selectedBlurEffectView)
    }
    
    required init?(coder : NSCoder) {
        fatalError()
    }
    
    func setBackgroundColor(color : UIColor) {
        if color != .clear {
            normalBlurEffectView.isHidden = true
            selectedBlurEffectView.isHidden = true
        }
        self.backgroundColor = color
    }
    
    func setTitleFont(font: ShopLiveFont) {
        self.titleTextLabel.adjustsFontSizeToFitWidth = true
        self.titleTextLabel.setFont(font: font)
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        myimageView.image = image
    }
    
    override var imageView: UIImageView? {
        return self.myimageView
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isUserInteractionEnabled || isHidden || alpha <= 0.01 {
            return nil
        }
        if self.point(inside: point, with: event) {
            for subview in subviews.reversed() {
                let convertedPoint = subview.convert(point, from: self)
                if let hitView = subview.hitTest(convertedPoint, with: event) {
                    return self
                }
            }
            return self
        }
        return nil
    }
}
extension SlBlurBGButton {
    private func setLayout() {
        self.addSubview(stack)
        stack.addArrangedSubview(myimageView)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.isLayoutMarginsRelativeArrangement = true
        self.addSubview(titleTextLabel)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            
            titleTextLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleTextLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleTextLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 6),
            titleTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -6),
            titleTextLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
}
