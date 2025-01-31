//
//  SDKConfiguration.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/28/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopLiveSDK
import ShopliveSDKCommon

struct SDKConfiguration {
    
    var user : ShopLiveCommonUser?
    var isGuestMode : Bool
    var useJWTToken : Bool
    var jwtToken : String?
    
    var stopVideoOnHeadphoneDisconnected : Bool
    var muteVideoOnHeadphoneDisconnected : Bool
    var useCallOption : Bool
    
    var useCustomShare : Bool
    var customShareScheme : String?
    
    var useCustomProgress : Bool
    var customProgressColor : String?
    
    var useCustomChatInputFont : Bool
    var useCustomChatSendButtonFont : Bool
    
    var downloadCouponSuccessMessage : String?
    var downloadCouponSucessStatus : ShopLiveResultStatus?
    var downloadCouponSuccessAlertType : ShopLiveResultAlertType?
    
    var downloadCoupontFailedMessage : String?
    var downloadCouponFailedStatus : ShopLiveResultStatus?
    var downloadCouponFailedAlertType : ShopLiveResultAlertType?
   
    // 고정값 아마 프로젝트 내부에 있냐 없냐로 그냥 구분 하는듯?
    var customFont : UIFont? = {
        let customFont: String = "NanumBrush"
        return UIFont(name: customFont, size: 16)
    }()
    
    var pipPosition : ShopLive.PipPosition?
    var pipPinPosition : [ShopLive.PipPosition]?
    
    var maxPipSize : CGFloat?
    var fixedHeightPipSize : CGFloat?
    var fixedWidthPipSize : CGFloat?
    var pipCornerRadius : CGFloat?
    var pipPadding : UIEdgeInsets
    var pipFloatingOffset : UIEdgeInsets
    var pipEnableSwipeOut : Bool
    var enablePip : Bool
    var enableOSPip : Bool
    
    var usePlayWhenPreviewTapped : Bool
    var useInAppPipCloseButton : Bool
    
    var nextActionTypeOnHandleNavigation : ActionType?
    
    var isMuted : Bool
    var enablePreviewSound : Bool
    var isEnabledVolumeKey : Bool

    
    var useKeepWindowStateOnPlayExecuted : Bool
    var usePipKeepWindowStyle : Bool
    var customLandingUrl : String?
    var useManualRotation : Bool
    var useMixAudio : Bool
    
    var customerAppVersion : String?
    var referrer : String?
    var adId : String?
    var anonId : String?
    var utmSource : String?
    var utmCampaign : String?
    var utmContent : String?
    var utmMedium : String?
    var queryParams : [String : Any]?
    
    
    var statusBarVisibility : Bool
    var resizeMode : ShopLiveResizeMode
    var previewResolution : ShopLivePlayerPreviewResolution
}
