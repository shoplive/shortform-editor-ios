//
//  Collection+extension.swift
//  ShopLiveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation

public extension Collection {
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    var isNotEmpty_SL: Bool {
        return !isEmpty
    }
}
