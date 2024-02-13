//
//  UITextField+extension.swift
//  ShopLiveSDKCommon
//
//  Created by Vincent on 1/25/23.
//

import UIKit

public extension UITextField {
    func setPlaceholderColor_SL(_ placeholderColor: UIColor) {
        attributedPlaceholder = NSAttributedString(
            string: placeholder ?? "",
            attributes: [
                .foregroundColor: placeholderColor,
                .font: font
            ].compactMapValues { $0 }
        )
    }
    
    func addUnderLine_SL() {
        self.borderStyle = .none
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.size.height-1, width: self.frame.width, height: 1)
        border.backgroundColor = UIColor.black.cgColor
        self.layer.addSublayer(border)
        self.textColor = UIColor.black
    }
}
