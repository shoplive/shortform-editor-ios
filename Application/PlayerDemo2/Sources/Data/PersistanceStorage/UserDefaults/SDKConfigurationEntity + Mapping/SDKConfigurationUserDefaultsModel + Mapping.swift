//
//  SDKConfigurationEntity + Mapping.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/28/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import ShopLiveSDK


extension SDKConfigurationUserDefaultsModel {
    
    
    func toEntity() -> SDKConfiguration {
        return .init(user: self.toShopLiveCommonUser(),
                     isGuestMode: isGuestMode,
                     useJWTToken: useJWTToken,
                     jwtToken: jwtToken,
                     userMode: userMode,
                     stopVideoOnHeadphoneDisconnected: stopVideoOnHeadphoneDisconnected,
                     muteVideoOnHeadphoneDisconnected: muteVideoOnHeadphoneDisconnected,
                     useCallOption: useCallOption,
                     
                     useCustomShare: useCustomShare,
                     customShareScheme: customShareScheme,
                     
                     useCustomProgress: useCustomProgress,
                     customProgressColor: customProgressColor,
                     
                     useCustomChatInputFont: useCustomChatInputFont,
                     useCustomChatSendButtonFont: useCustomChatSendButtonFont,
                     
                     downloadCouponSuccessMessage: downloadCouponSuccessMessage,
                     downloadCouponSucessStatus: downloadCouponSucessStatus,
                     downloadCouponSuccessAlertType: downloadCouponSuccessAlertType,
                     
                     downloadCoupontFailedMessage: downloadCoupontFailedMessage,
                     downloadCouponFailedStatus: downloadCouponFailedStatus,
                     downloadCouponFailedAlertType: downloadCouponFailedAlertType,
                     
                     pipPosition: pipPosition,
                     pipPinPosition: pipPinPosition,
                     maxPipSize : maxPipSize,
                     fixedHeightPipSize: fixedHeightPipSize,
                     fixedWidthPipSize : fixedWidthPipSize,
                     pipCornerRadius: pipCornerRadius,
                     pipPadding: pipPadding,
                     pipFloatingOffset: pipFloatingOffset,
                     pipEnableSwipeOut: pipEnableSwipeOut,
                     enablePip: enablePip,
                     enableOSPip: enableOSPip,
                     
                     usePlayWhenPreviewTapped: usePlayWhenPreviewTapped,
                     useInAppPipCloseButton: useInAppPipCloseButton,
                     
                     nextActionTypeOnHandleNavigation: nextActionTypeOnHandleNavigation,
                     
                     isMuted: isMuted,
                     enablePreviewSound: enablePreviewSound,
                     isEnabledVolumeKey: isEnabledVolumeKey,
                     
                     useKeepWindowStateOnPlayExecuted: useKeepWindowStateOnPlayExecuted,
                     usePipKeepWindowStyle: usePipKeepWindowStyle,
                     customLandingUrl: customLandingUrl,
                     useManualRotation: useManualRotation,
                     useMixAudio: useMixAudio,
                     
                     customerAppVersion: customerAppVersion,
                     referrer: referrer,
                     adId: adId,
                     anonId: anonId,
                     utmSource: utmSource,
                     utmCampaign: utmCampaign,
                     utmContent: utmContent,
                     utmMedium: utmMedium,
                     customParamter: self.customParamter?.dictionary,
                     
                     statusBarVisibility: statusBarVisibility,
                     resizeMode : resizeMode,
                     previewResolution: previewResolution)
        
        
    }
    
    func toShopLiveCommonUser() -> ShopLiveCommonUser? {
        guard let user = user else {
            return nil
        }
        
        return .init(userId: user.userId,
                     userName: user.useName,
                     age: user.age,
                     gender: user.gender.toShopLiveCommonUserGender(),
                     userScore: user.userScore,
                     custom: user.custom?.dictionary)
    }
}
