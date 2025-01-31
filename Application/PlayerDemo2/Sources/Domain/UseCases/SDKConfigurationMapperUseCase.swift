//
//  SDKConfigurationMapperUseCase.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/29/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import ShopLiveSDK



protocol SDKConfigurationMapperUseCase : NSObjectProtocol {
    func getValue(by key : SDKOptionType,from data : SDKConfiguration) -> Any?
    func setValue(by key : SDKOptionType,to data : SDKConfiguration, value : Any?) -> SDKConfiguration
}


final class DefaultSDKConfigurationMapperUseCase : NSObject, SDKConfigurationMapperUseCase {
   
    func getValue(by key: SDKOptionType,from data : SDKConfiguration) -> Any? {
        switch key {
        case .useCloseButton:
            return data.useInAppPipCloseButton
        case .playWhenPreviewTapped:
            return data.usePlayWhenPreviewTapped
        case .pipPosition:
            return data.pipPosition ?? .bottomRight
        case .pipPinPosition:
            return data.pipPinPosition ?? [.bottomRight]
        case .pipScale:
            return nil
        case .maxPipSize:
            return data.maxPipSize
        case .fixedHeightPipSize:
            return data.fixedHeightPipSize
        case .fixedWidthPipSize:
            return data.fixedWidthPipSize
        case .pipCornerRadius:
            return data.pipCornerRadius
        case .nextActionOnHandleNavigation:
            return data.nextActionTypeOnHandleNavigation
        case .headphoneOption1:
            return data.stopVideoOnHeadphoneDisconnected
        case .headphoneOption2:
            return data.muteVideoOnHeadphoneDisconnected
        case .callOption:
            return data.useCallOption
        case .customShare:
            return data.useCustomShare
        case .shareScheme:
            return data.customShareScheme
        case .progressColor:
            return data.customProgressColor
        case .customProgress:
            return data.useCustomProgress
        case .chatInputCustomFont:
            return data.useCustomChatInputFont
        case .chatSendButtonCustomFont:
            return data.useCustomChatSendButtonFont
        case .mute:
            return data.isMuted
        case .pipPadding:
            return data.pipPadding
        case .pipFloatingOffset:
            return data.pipFloatingOffset
        case .pipEnableSwipeOut:
            return data.pipEnableSwipeOut
        case .keepWindowStateOnPlayExecuted:
            return data.useKeepWindowStateOnPlayExecuted
        case .pipKeepWindowStyle:
            return data.usePipKeepWindowStyle
        case .manualRotation:
            return data.useManualRotation
        case .mixAudio:
            return data.useMixAudio
        case .addParameter:
            return data.queryParams
        case .statusBarVisibility:
            return data.statusBarVisibility
        case .previewResolution:
            return data.previewResolution
        case .enablePreviewSound:
            return data.enablePreviewSound
        case .enablePip:
            return data.enablePip
        case .enableOSPip:
            return data.enableOSPip
        case .resizeMode:
            return data.resizeMode
        case .isEnabledVolumeKey:
            return data.isEnabledVolumeKey
        }
    }
    
    func setValue(by key: SDKOptionType,to data : SDKConfiguration, value: Any?) -> SDKConfiguration {
        var newValue = data
        switch key {
        case .useCloseButton:
            newValue.useInAppPipCloseButton = value as? Bool ?? false
        case .playWhenPreviewTapped:
            newValue.usePlayWhenPreviewTapped = value as? Bool ?? false
        case .pipPosition:
            newValue.pipPosition = value as? ShopLive.PipPosition ?? .bottomRight
        case .pipPinPosition:
            newValue.pipPinPosition = value as? [ShopLive.PipPosition] ?? [.bottomRight]
        case .pipScale:
            break
        case .maxPipSize:
            newValue.maxPipSize = value as? CGFloat
        case .fixedHeightPipSize:
            newValue.fixedHeightPipSize = value as? CGFloat
        case .fixedWidthPipSize:
            newValue.fixedWidthPipSize = value as? CGFloat
        case .pipCornerRadius:
            newValue.pipCornerRadius = value as? CGFloat
        case .nextActionOnHandleNavigation:
            newValue.nextActionTypeOnHandleNavigation = value as? ActionType
        case .headphoneOption1:
            newValue.stopVideoOnHeadphoneDisconnected = value as? Bool ?? false
        case .headphoneOption2:
            newValue.muteVideoOnHeadphoneDisconnected = value as? Bool ?? false
        case .callOption:
            newValue.useCallOption = value as? Bool ?? false
        case .customShare:
            newValue.useCustomShare = value as? Bool ?? false
        case .shareScheme:
            newValue.customShareScheme = value as? String
        case .progressColor:
            newValue.customProgressColor = value as? String
        case .customProgress:
            newValue.useCustomProgress = value as? Bool ?? false
        case .chatInputCustomFont:
            newValue.useCustomChatInputFont = value as? Bool ?? false
        case .chatSendButtonCustomFont:
            newValue.useCustomChatSendButtonFont = value as? Bool ?? false
        case .mute:
            newValue.isMuted = value as? Bool ?? false
        case .pipPadding:
            newValue.pipPadding = value as? UIEdgeInsets ?? .init(top: 20, left: 20, bottom: 20, right: 20)
        case .pipFloatingOffset:
            newValue.pipFloatingOffset = value as? UIEdgeInsets ?? .init(top: 20, left: 20, bottom: 20, right: 20)
        case .pipEnableSwipeOut:
            newValue.pipEnableSwipeOut = value as? Bool ?? false
        case .keepWindowStateOnPlayExecuted:
            newValue.useKeepWindowStateOnPlayExecuted = value as? Bool ?? false
        case .pipKeepWindowStyle:
            newValue.usePipKeepWindowStyle = value as? Bool ?? false
        case .manualRotation:
            newValue.useManualRotation = value as? Bool ?? false
        case .mixAudio:
            newValue.useMixAudio = value as? Bool ?? false
        case .addParameter:
            newValue.queryParams = value as? [String : Any]
        case .statusBarVisibility:
            newValue.statusBarVisibility = value as? Bool ?? true
        case .previewResolution:
            newValue.previewResolution = value as? ShopLivePlayerPreviewResolution ?? .LIVE
        case .enablePreviewSound:
            newValue.enablePreviewSound = value as? Bool ?? false
        case .enablePip:
            newValue.enablePip = value as? Bool ?? true
        case .enableOSPip:
            newValue.enableOSPip = value as? Bool ?? true
        case .resizeMode:
            newValue.resizeMode = value as? ShopLiveResizeMode ?? .CENTER_CROP
        case .isEnabledVolumeKey:
            newValue.isEnabledVolumeKey = value as? Bool ?? true
        }
        
        return newValue
    }
}


