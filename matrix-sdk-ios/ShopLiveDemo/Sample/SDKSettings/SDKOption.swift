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
    case useCloseButton
    case playWhenPreviewTapped
    case pipPosition
    case pipScale
    case maxPipSize
    case nextActionOnHandleNavigation
    case headphoneOption1
    case headphoneOption2
    case callOption
    case customShare
    case shareScheme
    case progressColor
    case customProgress
    case chatInputCustomFont
    case chatSendButtonCustomFont
    case mute
    case pipPadding
    case pipFloatingOffset
    case pipMarginTop
    case pipMarginBottom
    case pipEnableSwipeOut
    case aspectOnTablet
    case keepWindowStateOnPlayExecuted
    case pipKeepWindowStyle
    case manualRotation
    case mixAudio
    case clicklog
    case addParameter
    case enablePictureInPictureMode
    case automaticallyPreservesTimeOffsetFromLive
    case startsOnFirstEligibleVariant
    case variantPreferences_scalabilityToLosslessAudio

    enum SettingType: Int {
        case showAlert
        case switchControl
        case dropdown
        case routeTo
    }

    var settingType: SettingType {
        switch self {
        case .shareScheme, .progressColor, .pipScale, .maxPipSize:
            return .showAlert
        case .pipPosition, .nextActionOnHandleNavigation:
            return .dropdown
        case .pipFloatingOffset, .addParameter:
            return .routeTo
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
