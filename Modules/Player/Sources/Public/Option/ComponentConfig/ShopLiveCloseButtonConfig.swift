//
//  ShopLiveCloseButtonConfig.swift
//  ShopLiveSDK
//
//  Created by Kio on 12/1/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopliveSDKCommon

/// 블러 마스크 스타일을 정의하는 열거형
@objc public enum ShopLiveBlurMaskStyle: Int {
    /// 일반 블러 효과
    case normal = 0
    /// 솔리드 블러 효과
    case solid = 1
    /// 내부 블러 효과
    case inner = 2
    /// 외부 블러 효과
    case outer = 3
    
    /// 스타일을 문자열로 변환
    public var stringValue: String {
        switch self {
        case .normal: return "NORMAL"
        case .solid: return "SOLID"
        case .inner: return "INNER"
        case .outer: return "OUTER"
        }
    }
    
    /// 문자열로부터 블러 마스크 스타일을 생성
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

///
///
/// Close 버튼의 외형과 위치를 커스터마이징하기 위한 설정 클래스 - Preview 모드의 Close 버튼의 위치, 크기, 색상, 그림자 효과 등을 설정할 수 있습니다.
@objc public class ShopLiveCloseButtonConfig: NSObject {
    /// Close 버튼의 위치 (.topLeft 또는 .topRight)
    public var position: ShopLive.PreviewCloseButtonPositionConfig?
    /// 버튼의 너비 (기본값: 30)
    public var width: CGFloat?
    /// 버튼의 높이 (기본값: 30)
    public var height: CGFloat?
    /// 버튼의 X축 오프셋 (기본값: 3)
    public var offsetX: CGFloat?
    /// 버튼의 Y축 오프셋 (기본값: 3)
    public var offsetY: CGFloat?
    /// 버튼의 색상 (기본값: .white)
    public var color: UIColor?
    /// 그림자의 X축 오프셋
    public var shadowOffsetX: CGFloat?
    /// 그림자의 Y축 오프셋
    public var shadowOffsetY: CGFloat?
    /// 그림자의 블러 반경
    public var shadowBlur: CGFloat?
    /// 그림자의 블러 스타일
    public var shadowBlurStyle: ShopLiveBlurMaskStyle?
    /// 그림자의 색상
    public var shadowColor: UIColor?
    /// 커스텀 이미지 URL 문자열
    public var imageStr: String?
    
    /// ShopLiveCloseButtonConfig 초기화
    /// - Parameters:
    ///   - position: Close 버튼의 위치 (기본값: .topLeft)
    ///   - width: 버튼의 너비 (기본값: 30)
    ///   - height: 버튼의 높이 (기본값: 30)
    ///   - offsetX: 버튼의 X축 오프셋 (기본값: 3)
    ///   - offsetY: 버튼의 Y축 오프셋 (기본값: 3)
    ///   - color: 버튼의 색상 (기본값: .white)
    ///   - shadowOffsetX: 그림자의 X축 오프셋
    ///   - shadowOffsetY: 그림자의 Y축 오프셋
    ///   - shadowBlur: 그림자의 블러 반경
    ///   - shadowBlurStyle: 그림자의 블러 스타일
    ///   - shadowColor: 그림자의 색상
    ///   - imageStr: 커스텀 이미지 URL 문자열
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
    
    /// ShopLiveCloseButtonConfig를 JSON 문자열로 변환
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
    
    /// JSON 문자열로부터 ShopLiveCloseButtonConfig를 생성
    public static func fromJSON(_ jsonString: String) -> ShopLiveCloseButtonConfig? {
        guard let jsonData = jsonString.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return nil
        }
        
        return ShopLiveCloseButtonConfig(
            position: parsePosition(from: dict["position"]),
            width: SLJSONUtil.parseCGFloat(from: dict["width"]),
            height: SLJSONUtil.parseCGFloat(from: dict["height"]),
            offsetX: SLJSONUtil.parseCGFloat(from: dict["offsetX"]),
            offsetY: SLJSONUtil.parseCGFloat(from: dict["offsetY"]),
            color: SLJSONUtil.parseColor(from: dict["color"]),
            shadowOffsetX: SLJSONUtil.parseCGFloat(from: dict["shadowOffsetX"]),
            shadowOffsetY: SLJSONUtil.parseCGFloat(from: dict["shadowOffsetY"]),
            shadowBlur: SLJSONUtil.parseCGFloat(from: dict["shadowBlur"]),
            shadowBlurStyle: parseBlurStyle(from: dict["shadowBlurStyle"]),
            shadowColor: SLJSONUtil.parseColor(from: dict["shadowColor"]),
            imageStr: SLJSONUtil.parseString(from: dict["imageStr"])
        )
    }
    
    // MARK: - JSON Parsing Helpers
    
    /// JSON에서 position 값을 파싱
    private static func parsePosition(from value: Any?) -> ShopLive.PreviewCloseButtonPositionConfig? {
        guard let positionStr = value as? String else { return nil }
        switch positionStr {
        case ShopLive.PreviewCloseButtonPositionConfig.topLeft.name: return .topLeft
        case ShopLive.PreviewCloseButtonPositionConfig.topRight.name: return .topRight
        default: return nil
        }
    }
    
    /// JSON에서 ShopLiveBlurMaskStyle 값을 파싱
    private static func parseBlurStyle(from value: Any?) -> ShopLiveBlurMaskStyle? {
        if let styleInt = value as? Int {
            return ShopLiveBlurMaskStyle(rawValue: styleInt)
        } else if let styleStr = value as? String, !styleStr.isEmpty {
            return ShopLiveBlurMaskStyle.from(string: styleStr)
        }
        return nil
    }
    
    /// 데모앱 JSON 문자열 형식을 검증
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
