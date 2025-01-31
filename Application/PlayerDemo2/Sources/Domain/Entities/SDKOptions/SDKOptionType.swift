//
//  SDKOptionType.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/29/25.
//  Copyright © 2025 com.app. All rights reserved.
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
    case pipPinPosition
    case pipScale
    case maxPipSize
    case fixedHeightPipSize
    case fixedWidthPipSize
    case pipCornerRadius
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
    case pipEnableSwipeOut
    case keepWindowStateOnPlayExecuted
    case pipKeepWindowStyle
    case manualRotation
    case mixAudio
    case addParameter
    case statusBarVisibility
    case previewResolution
    case enablePreviewSound
    case enablePip
    case enableOSPip
    case resizeMode
    case isEnabledVolumeKey

    
    enum SettingType: Int {
        case showAlert
        case switchControl
        case dropdown
        case routeTo
    }

    var settingType: SettingType {
        switch self {
        case .shareScheme, .progressColor, .pipScale, .maxPipSize, .fixedHeightPipSize, .fixedWidthPipSize, .pipCornerRadius:
            return .showAlert
        case .pipPosition, .nextActionOnHandleNavigation, .resizeMode, .previewResolution:
            return .dropdown
        case .pipFloatingOffset, .addParameter, .pipPinPosition:
            return .routeTo
        default:
            return .switchControl
        }
    }

    var optionKey: String {
        self.rawValue
    }
}
