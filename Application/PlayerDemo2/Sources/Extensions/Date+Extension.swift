//
//  Date+Extension.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

extension Date {
    static var expiredTime: Int {
        Int(Date(timeIntervalSinceNow: 60 * 60 * 12).timeIntervalSince1970)
    }

    static var createdTime: Int {
        Int(Date().timeIntervalSince1970)
    }
}
