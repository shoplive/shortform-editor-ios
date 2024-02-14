//
//  UIFont+extension.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation
import UIKit

public extension UIFont {
    func findAvailableFont_SL() -> UIFont {
        var fontSize: CGFloat = 30
        var currentLineHeight: CGFloat = self.lineHeight
        
        guard currentLineHeight > 20 else {
            return self
        }
        
        repeat {
            currentLineHeight = self.withSize(fontSize).lineHeight
            fontSize -= 1
        } while 20 < currentLineHeight && fontSize >= 0
        
        return fontSize == 0 ? .systemFont(ofSize: 14, weight: .regular) : self.withSize(fontSize)
    }
    
    func lineHeightMultiple_SL(_ lineHeight: CGFloat = 20) -> CGFloat {
        return lineHeight / self.lineHeight
    }
}
