//
//  SLLabelButton.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/18/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit


class SLLabelButton : UIButton {
    
    
    let titleTextLabel : UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textAlignment = .center
        return label
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
extension SLLabelButton {
    private func setLayout() {
        self.addSubview(titleTextLabel)
        
        NSLayoutConstraint.activate([
            titleTextLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            titleTextLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            titleTextLabel.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 6),
            titleTextLabel.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -6),
            titleTextLabel.heightAnchor.constraint(equalToConstant: 16)
        ])
    }
    
}
