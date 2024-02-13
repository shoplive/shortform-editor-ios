//
//  Date+extension.swift
//  ShopLiveSDKCommon
//
//  Created by Vincent on 1/25/23.
//

import Foundation

public extension Date {
    static var expiredTime_SL: Int {
        Int(Date(timeIntervalSinceNow: 60 * 60 * 12).timeIntervalSince1970)
    }

    static var createdTime_SL: Int {
        Int(Date().timeIntervalSince1970)
    }
}
