//
//  ShopLiveHapticManager.swift
//  ShopLiveSDKCommon
//
//  Created by sangmin han on 2023/05/24.
//

import Foundation
import UIKit

public class ShopLiveHapticManager {
    
    public static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style)
        if #available(iOS 13.0, *) {
            impactFeedbackGenerator.impactOccurred(intensity: 1.0)
        } else {
            impactFeedbackGenerator.impactOccurred()
        }
    }
}

public enum ShopLiveHapticStyle: String {
    case LIGHT
    case MEDIUM
    case HEAVY
    
    public var style: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .LIGHT:
            return .light
        case .MEDIUM:
            return .medium
        case .HEAVY:
            return .heavy
        }
    }
}
