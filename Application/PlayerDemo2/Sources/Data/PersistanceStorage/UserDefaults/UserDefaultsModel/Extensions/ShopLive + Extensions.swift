//
//  ShopLive + Extensions.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/31/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import ShopLiveSDK

extension ShopLivePlayerPreviewResolution : Codable {
    
}
extension ActionType : Codable {
    
}
extension ShopLiveResizeMode : Codable {
    
}
extension ShopLive.PipPosition : Codable {
    
}
extension ShopLiveResultStatus : Codable {
    
}
extension ShopLiveResultAlertType : Codable {
    
}
extension ShopliveCommonUserGender {
    func commonGenderToGender() -> Gender {
        switch self {
        case .male:
            return .male
        case.female:
            return .female
        case .netural:
            return .netural
        }
    }
}


