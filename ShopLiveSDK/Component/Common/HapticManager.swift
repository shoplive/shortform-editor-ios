//
//  HapticManager.swift
//  ShopLiveSDK
//
//  Created by 김우현 on 2022/01/19.
//

import Foundation
import UIKit

class HapticManager {
    
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: style)
        if #available(iOS 13.0, *) {
            impactFeedbackGenerator.impactOccurred(intensity: 1.0)
        } else {
            impactFeedbackGenerator.impactOccurred()
        }
    }
}

enum HapticStyle: String {
    case LIGHT
    case MEDIUM
    case HEAVY
    
    var style: UIImpactFeedbackGenerator.FeedbackStyle {
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
