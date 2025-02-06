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


extension SDKConfiguration {
    func toUserDefaultsModel() -> SDKConfigurationUserDefaultsModel {
        return .init(user: self.commonUserToUser(),
                     isGuestMode: isGuestMode,
                     useJWTToken: useJWTToken,
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
                     
                     
                     pipPosition : pipPosition,
                     pipPinPosition : pipPinPosition,
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
                     queryParams: queryParamsToCodableDict(),
                     
                     statusBarVisibility: statusBarVisibility,
                     resizeMode : resizeMode,
                     previewResolution: previewResolution)
        
    }
    
    
    func commonUserToUser() -> User? {
        guard let user = user else {
            return nil
        }
        
        var custom : CodableDictionary?
        if let customDict = user.custom {
            custom = CodableDictionary(dictionary: customDict)
        }
        
        return .init(userId: user.userId,
                     useName: user.userName,
                     age: user.age,
                     gender: user.gender?.commonGenderToGender() ?? .netural,
                     userScore: user.userScore,
                     custom: custom )
    }
    
    func queryParamsToCodableDict() -> CodableDictionary? {
        if let queryParams = self.queryParams {
            return CodableDictionary(dictionary: queryParams)
        }
        return nil
    }
}
