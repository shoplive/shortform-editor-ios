//
//  ShopLiveFileSizeConverter.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 3/22/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation

struct ShopliveFileSizeConverter {
    static func bytesToKB(_ bytes: UInt64) -> Double {
        return Double(bytes) / 1024.0
    }

    static func bytesToMB(_ bytes: UInt64) -> Double {
        return Double(bytes) / (1024.0 * 1024.0)
    }

    static func bytesToGB(_ bytes: UInt64) -> Double {
        return Double(bytes) / (1024.0 * 1024.0 * 1024.0)
    }
    
    static func convertFileSize(_ bytes: UInt64) -> String {
        // Determine the appropriate unit based on the size of bytes
        var size: Double = Double(bytes)
        var unit: String = "bytes"
        
        if size >= 1024 {
            size /= 1024.0
            unit = "KB"
        }
        
        if size >= 1024 {
            size /= 1024.0
            unit = "MB"
        }
        
        if size >= 1024 {
            size /= 1024.0
            unit = "GB"
        }
        
        let formattedSize = String(format: "%.1f", size)
        return "\(formattedSize)\(unit)"
    }
    
}
