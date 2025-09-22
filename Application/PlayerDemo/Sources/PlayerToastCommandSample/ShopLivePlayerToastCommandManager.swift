//
//  ShopLivePlayerToastCommandManager.swift
//  ShopLivePlayerDemo
//
//  Created by sangmin han on 4/23/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import ShopLiveSDK



class ShopLivePlayerToastCommandManager {
    static let shared = ShopLivePlayerToastCommandManager()
    
    enum Position: String {
        case top = "TOP"
        case center = "CENTER"
        case bottom = "BOTTOM"
    }
    
//    command: SHOW_LAYER_TOAST
//    payload:
//    {
//      message: string // 필수
//      duration: number // optional, 표시될 시간 milliseconds
//      position: string // optional "TOP" | "BOTTOM" | "CENTER"
//    }
    func showToast(message: String, duration: Int = 1000, position: Position = .center) {
        var payload: [String: Any] = [:]
        payload["message"] = message
        payload["duration"] = duration
        payload["position"] = position.rawValue
        ShopLive.sendCommandMessage(command: "SHOW_LAYER_TOAST", payload: payload)
    }
    
}
