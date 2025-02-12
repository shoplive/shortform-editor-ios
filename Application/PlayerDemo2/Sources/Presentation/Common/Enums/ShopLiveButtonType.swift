//
//  ShopLiveButtonType.swift
//  PlayerDemo2
//
//  Created by Tabber on 2/10/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

enum ShopLiveButtonType: CaseIterable {
    case webDebug
    case useLockPortrait
    case useCustomParam
    
    // DevInfo
    case DEV
    case QA
    case STAGE
    case REAL
    case CUSTOM
    
    var stringValue: String {
        switch self {
        case .webDebug: "webDebug"
        case .useLockPortrait: "useLockPortrait"
        case .useCustomParam: "useCustomParam"
        case .DEV: "DEV"
        case .QA: "QA"
        case .STAGE: "STAGE"
        case .REAL: "REAL"
        case .CUSTOM: "CUSTOM"
        }
    }
    
    var description: String? {
        switch self {
        case .webDebug: "웹 디버깅 로그 출력하기"
        case .useLockPortrait: "세로방향 고정하기"
        case .useCustomParam: "use Param"
        case .DEV: "DEV Player"
        case .QA: "QA Player"
        case .STAGE: "STAGE Player"
        case .REAL: "REAL Player"
        case .CUSTOM: "랜딩 URL 직접 입력"
        }
    }
    
    static func convert(_ value: String) -> ShopLiveButtonType? {
        switch value {
        case "DEV": .DEV
        case "QA": .QA
        case "STAGE": .STAGE
        case "REAL": .REAL
        case "CUSTOM": .CUSTOM
        case "webDebug": .webDebug
        case "useLockPortrait": .useLockPortrait
        case "useCustomParam": .useCustomParam
        default: nil
        }
    }
}
