//
//  ShopLiveCloseButtonConfig.swift
//  ShopLiveSDK
//
//  Created by Kio on 12/1/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

@objc public enum ShopLiveBlurMaskStyle: Int {
    case normal = 0
    case solid = 1
    case inner = 2
    case outer = 3
    
    public var stringValue: String {
        switch self {
        case .normal: return "NORMAL"
        case .solid: return "SOLID"
        case .inner: return "INNER"
        case .outer: return "OUTER"
        }
    }
    
    public static func from(string: String) -> ShopLiveBlurMaskStyle? {
        switch string {
        case "NORMAL": return .normal
        case "SOLID": return .solid
        case "INNER": return .inner
        case "OUTER": return .outer
        default: return nil
        }
    }
}

@objc public class ShopLiveCloseButtonConfig: NSObject {
    public var position: ShopLive.PreviewCloseButtonPositionConfig?
    public var width: CGFloat?
    public var height: CGFloat?
    public var offsetX: CGFloat?
    public var offsetY: CGFloat?
    public var color: UIColor?
    public var shadowOffsetX: CGFloat?
    public var shadowOffsetY: CGFloat?
    public var shadowBlur: CGFloat?
    public var shadowBlurStyle: ShopLiveBlurMaskStyle?
    public var shadowColor: UIColor?
    public var imageStr: String?
    
    public init(
        position: ShopLive.PreviewCloseButtonPositionConfig? = .topLeft,
        width: CGFloat? = 30,
        height: CGFloat? = 30,
        offsetX: CGFloat? = 3,
        offsetY: CGFloat? = 3,
        color: UIColor? = .white,
        shadowOffsetX: CGFloat? = nil,
        shadowOffsetY: CGFloat? = nil,
        shadowBlur: CGFloat? = nil,
        shadowBlurStyle: ShopLiveBlurMaskStyle? = nil,
        shadowColor: UIColor? = nil,
        imageStr: String? = nil
    ) {
        self.position = position
        self.width = width
        self.height = height
        self.offsetX = offsetX
        self.offsetY = offsetY
        self.color = color
        self.shadowOffsetX = shadowOffsetX
        self.shadowOffsetY = shadowOffsetY
        self.shadowBlur = shadowBlur
        self.shadowBlurStyle = shadowBlurStyle
        self.shadowColor = shadowColor
        self.imageStr = imageStr
        super.init()
    }
    
    // MARK: - JSON Conversion
    
    /// Convert ShopLiveCloseButtonConfig to JSON string
    public func toJSON() -> String {
        var dict: [String: Any] = [:]
        
        if let position = position {
            dict["position"] = position.name
        }
        if let width = width {
            dict["width"] = width
        }
        if let height = height {
            dict["height"] = height
        }
        if let offsetX = offsetX {
            dict["offsetX"] = offsetX
        }
        if let offsetY = offsetY {
            dict["offsetY"] = offsetY
        }
        if let color = color {
            dict["color"] = color.toHexString()
        }
        if let shadowOffsetX = shadowOffsetX {
            dict["shadowOffsetX"] = shadowOffsetX
        }
        if let shadowOffsetY = shadowOffsetY {
            dict["shadowOffsetY"] = shadowOffsetY
        }
        if let shadowBlur = shadowBlur {
            dict["shadowBlur"] = shadowBlur
        }
        if let shadowBlurStyle = shadowBlurStyle {
            dict["shadowBlurStyle"] = shadowBlurStyle.stringValue
        }
        if let shadowColor = shadowColor {
            dict["shadowColor"] = shadowColor.toHexString()
        }
        if let imageStr = imageStr, !imageStr.isEmpty {
            dict["imageStr"] = imageStr
        }
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [.prettyPrinted]),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return "{}"
        }
        return jsonString
    }
    
    /// Create ShopLiveCloseButtonConfig from JSON string
    public static func fromJSON(_ jsonString: String) -> ShopLiveCloseButtonConfig? {
        guard let jsonData = jsonString.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return nil
        }
        
        return ShopLiveCloseButtonConfig(
            position: parsePosition(from: dict["position"]),
            width: parseCGFloat(from: dict["width"]),
            height: parseCGFloat(from: dict["height"]),
            offsetX: parseCGFloat(from: dict["offsetX"]),
            offsetY: parseCGFloat(from: dict["offsetY"]),
            color: parseColor(from: dict["color"]),
            shadowOffsetX: parseCGFloat(from: dict["shadowOffsetX"]),
            shadowOffsetY: parseCGFloat(from: dict["shadowOffsetY"]),
            shadowBlur: parseCGFloat(from: dict["shadowBlur"]),
            shadowBlurStyle: parseBlurStyle(from: dict["shadowBlurStyle"]),
            shadowColor: parseColor(from: dict["shadowColor"]),
            imageStr: parseString(from: dict["imageStr"])
        )
    }
    
    // MARK: - JSON Parsing Helpers
    
    private static func parsePosition(from value: Any?) -> ShopLive.PreviewCloseButtonPositionConfig? {
        guard let positionStr = value as? String else { return nil }
        switch positionStr {
        case "TOP_LEFT": return .topLeft
        case "TOP_RIGHT": return .topRight
        default: return nil
        }
    }
    
    private static func parseCGFloat(from value: Any?) -> CGFloat? {
        if let number = value as? NSNumber {
            return CGFloat(number.doubleValue)
        }
        return nil
    }
    
    private static func parseColor(from value: Any?) -> UIColor? {
        guard let colorStr = value as? String, !colorStr.isEmpty else { return nil }
        return UIColor(hexString: colorStr)
    }
    
    private static func parseBlurStyle(from value: Any?) -> ShopLiveBlurMaskStyle? {
        if let styleInt = value as? Int {
            return ShopLiveBlurMaskStyle(rawValue: styleInt)
        } else if let styleStr = value as? String, !styleStr.isEmpty {
            return ShopLiveBlurMaskStyle.from(string: styleStr)
        }
        return nil
    }
    
    private static func parseString(from value: Any?) -> String? {
        guard let str = value as? String, !str.isEmpty else { return nil }
        return str
    }
    
    /// Validate JSON string format
    public static func validateJSON(_ jsonString: String) -> (isValid: Bool, errorMessage: String?) {
        // JSON 형식 검사
        guard let jsonData = jsonString.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return (false, "올바른 JSON 형식이 아닙니다.")
        }
        
        // position 검사 (선택사항)
        if let positionStr = dict["position"] as? String {
            let validPositions = ["TOP_LEFT", "TOP_RIGHT"]
            if !validPositions.contains(positionStr) {
                return (false, "position은 'TOP_LEFT' 또는 'TOP_RIGHT'만 가능합니다.")
            }
        }
        
        // 숫자 필드 검사
        let numberFields = ["width", "height", "offsetX", "offsetY", "shadowOffsetX", "shadowOffsetY", "shadowBlur"]
        for field in numberFields {
            if let value = dict[field] {
                if !(value is NSNumber) {
                    return (false, "\(field)는 숫자여야 합니다.")
                }
            }
        }
        
        // color 형식 검사 (선택사항)
        if let colorStr = dict["color"] as? String {
            if !colorStr.isEmpty && (!colorStr.hasPrefix("#") || (colorStr.count != 7 && colorStr.count != 9)) {
                return (false, "color는 '#RRGGBB' 또는 '#RRGGBBAA' 형식이어야 합니다.")
            }
        }
        
        // shadowColor 형식 검사 (선택사항)
        if let shadowColorStr = dict["shadowColor"] as? String {
            // 빈 문자열은 nil로 처리되므로 허용
            if !shadowColorStr.isEmpty && (!shadowColorStr.hasPrefix("#") || (shadowColorStr.count != 7 && shadowColorStr.count != 9)) {
                return (false, "shadowColor는 '#RRGGBB' 또는 '#RRGGBBAA' 형식이어야 합니다.")
            }
        }
        
        // shadowBlurStyle 검사 (선택사항)
        if let styleRaw = dict["shadowBlurStyle"] {
            if let styleInt = styleRaw as? Int {
                if styleInt < 0 || styleInt > 3 {
                    return (false, "shadowBlurStyle은 0~3 사이의 값이어야 합니다. (0:NORMAL, 1:SOLID, 2:INNER, 3:OUTER)")
                }
            } else if let styleStr = styleRaw as? String {
                // 빈 문자열은 nil로 처리되므로 허용
                if !styleStr.isEmpty {
                    let validStyles = ["NORMAL", "SOLID", "INNER", "OUTER"]
                    if !validStyles.contains(styleStr) {
                        return (false, "shadowBlurStyle은 'NORMAL', 'SOLID', 'INNER', 'OUTER' 중 하나여야 합니다.")
                    }
                }
            } else {
                return (false, "shadowBlurStyle은 정수(0-3) 또는 문자열('NORMAL', 'SOLID', 'INNER', 'OUTER')이어야 합니다.")
            }
        }
        
        return (true, nil)
    }
}

// MARK: - UIColor Extension for Hex Conversion
extension UIColor {
    func toHexString() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        
        getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rgb: Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        
        if a < 1.0 {
            return String(format: "#%06x%02x", rgb, Int(a*255))
        } else {
            return String(format: "#%06x", rgb)
        }
    }
    
    convenience init?(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        
        guard Scanner(string: hex).scanHexInt64(&int) else {
            return nil
        }
        
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (r, g, b, a) = (int >> 16, int >> 8 & 0xFF, int & 0xFF, 255)
        case 8: // RGBA (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: CGFloat(a) / 255
        )
    }
}
