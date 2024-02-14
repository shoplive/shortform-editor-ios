//
//  NSAttributedString+extension.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation

public extension NSAttributedString {
    var fullRange_SL: NSRange {
        return _NSRange.init(location: 0, length: self.length)
    }
}
