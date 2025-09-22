//
//  SLButton.swift
//  ShopliveSDKCommon
//
//  Created by Tabber on 2/12/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

public class SLButton: UIButton {
    let identity: String = "ShopLiveViewComponents"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setFont(font: ShopLiveFont) {
        if let customFont = font.customFont {
            self.titleLabel?.font = customFont
        } else if let defultFont = ShopLiveCommon.getFontFamily() {
            self.titleLabel?.font = defultFont.withSize(font.size)
        } else {
            self.titleLabel?.font = .systemFont(ofSize: font.size, weight: font.weight)
        }
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if !isUserInteractionEnabled || isHidden || alpha <= 0.01 {
            return nil
        }
        if self.point(inside: point, with: event) {
            for subview in subviews.reversed() {
                let convertedPoint = subview.convert(point, from: self)
                if let _ = subview.hitTest(convertedPoint, with: event) {
                    return self
                }
            }
            return self
        }
        return nil
    }
}

