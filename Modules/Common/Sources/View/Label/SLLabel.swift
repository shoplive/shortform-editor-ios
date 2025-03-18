//
//  SLLabel.swift
//  ShopliveSDKCommon
//
//  Created by Tabber on 2/12/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

public class SLLabel: UILabel {
    let identity : String = "ShopLiveViewComponents"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setFont(font: ShopLiveFont) {
        if let customFont = font.customFont {
            self.font = customFont
        } else if let defaultFont = ShopLiveCommon.getFontFamily() {
            self.font = defaultFont.withSize(font.size)
        } else {
            self.font = .systemFont(ofSize: font.size, weight: font.weight)
        }
    }
    
    public func setAttributedFont(font: ShopLiveFont) {
        let attributedFont: UIFont
        
        if let customFont = font.customFont {
            attributedFont = customFont
        } else if let defultFont = ShopLiveCommon.getFontFamily() {
            attributedFont = defultFont.withSize(font.size)
        } else {
            attributedFont = .systemFont(ofSize: font.size, weight: font.weight)
        }
        
        if let attributedText = self.attributedText {
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedText)
            mutableAttributedString.addAttribute(.font, value: attributedFont, range: NSRange(location: 0, length: mutableAttributedString.length))
            self.attributedText = mutableAttributedString
        } else if let text = self.text {
            let attributes: [NSAttributedString.Key: Any] = [ .font: attributedFont ]
            self.attributedText = NSAttributedString(string: text, attributes: attributes)
        }
    }
}
