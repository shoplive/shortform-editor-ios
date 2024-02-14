//
//  UITextView+extension.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation
import UIKit

public extension UITextView {
    func numberOfLines_SL(lineHeight: CGFloat = 20) -> Int {
        let size = CGSize(width: frame.width, height: .infinity)
        let estimatedSize = sizeThatFits(size)
        
        return Int(estimatedSize.height / lineHeight)
    }
}
