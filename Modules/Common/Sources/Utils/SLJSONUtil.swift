//
//  SLJSONUtil.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2/27/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import UIKit

public struct SLJSONUtil {
    public static func toJsonString(_ value: Encodable) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(value)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        }
        catch(_) {
            return nil
        }
    }
    
    // MARK: - JSON Parsing Helpers
    /// JSON에서 CGFloat 값을 파싱
    public static func parseCGFloat(from value: Any?) -> CGFloat? {
        if let number = value as? NSNumber {
            return CGFloat(number.doubleValue)
        }
        return nil
    }
    
    /// JSON에서 UIColor 값을 파싱 (헥스 문자열 형식: #RRGGBB 또는 #RRGGBBAA 형식)
    public static func parseColor(from value: Any?) -> UIColor? {
        guard let colorStr = value as? String, !colorStr.isEmpty else { return nil }
        return UIColor(hexString: colorStr)
    }
    
    /// JSON에서 String 값을 파싱
    public static func parseString(from value: Any?) -> String? {
        guard let str = value as? String, !str.isEmpty else { return nil }
        return str
    }
}
