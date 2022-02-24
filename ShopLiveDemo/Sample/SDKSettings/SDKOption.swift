//
//  SDKOption.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/17.
//

import Foundation

enum CouponResponseKey: String {
    case downloadCouponSuccessMessage
    case downloadCouponSuccessStatus
    case downloadCouponSuccessAlertType
    case downloadCouponFailedMessage
    case downloadCouponFailedStatus
    case downloadCouponFailedAlertType

    var key: String {
        self.rawValue
    }
}

enum SDKOptionType: String, CaseIterable {
    case playWhenPreviewTapped
    case pipPosition
    case pipScale
    case nextActionOnHandleNavigation
    case headphoneOption1
    case callOption
    case customShare
    case shareScheme
    case progressColor
    case customProgress
    case chatInputCustomFont
    case chatSendButtonCustomFont

    enum SettingType: Int {
        case showAlert
        case switchControl
        case dropdown
    }

    var settingType: SettingType {
        switch self {
        case .shareScheme, .progressColor, .pipScale:
            return .showAlert
        case .pipPosition, .nextActionOnHandleNavigation:
            return .dropdown
        default:
            return .switchControl
        }
    }

    var optionKey: String {
        self.rawValue
    }
}

struct SDKOptionItem {
    var name: String
    var optionDescription: String
    var optionType: SDKOptionType
}

struct SDKOption {
    var optionTitle: String
    var optionItems: [SDKOptionItem] = []
}
