//
//  ShopLiveSDKDelegate.swift
//  ShopLiveSDK
//
//  Created by yong C on 8/6/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopliveSDKCommon

@objc public protocol ShopLiveSDKDelegate: AnyObject {
    
    @objc func handleNavigation(with url: URL)
    
    
    @available(*, deprecated, message: "use handleDownloadCoupon(with couponId: String, result: @escaping (ShopLiveCouponResult) -> Void) instead")
    @objc optional func handleDownloadCouponResult(with couponId: String, completion: @escaping (CouponResult) -> Void)
    @objc optional func handleDownloadCoupon(with couponId: String, result: @escaping (ShopLiveCouponResult) -> Void)
    
    @available(*, deprecated, message: "use handleDownloadCoupon(with couponId: String, result: @escaping (ShopLiveCouponResult) -> Void) instead")
    @objc optional func handleDownloadCoupon(with couponId: String, completion: @escaping () -> Void)
    @available(*, deprecated, message: "use handleCustomAction(with id: String, type: String, payload: Any?, result: @escaping (ShopLiveCustomActionResult) -> Void) instead")
    @objc optional func handleCustomActionResult(with id: String, type: String, payload: Any?, completion: @escaping (CustomActionResult) -> Void)
    
    @available(*, deprecated, message: "use handleCustomAction(with id: String, type: String, payload: Any?, result: @escaping (ShopLiveCustomActionResult) -> Void) instead")
    @objc optional func handleCustomAction(with id: String, type: String, payload: Any?, completion: @escaping () -> Void)
    @objc optional func handleCustomAction(with id: String, type: String, payload: Any?, result: @escaping (ShopLiveCustomActionResult) -> Void)

    @objc optional func handleChangeCampaignStatus(status: String)
    @objc optional func handleChangedPlayerStatus(status: String)
    @objc optional func handleError(code: String, message: String)
    @objc optional func handleCampaignInfo(campaignInfo: [String: Any])
    
    @objc optional func onSetUserName(_ payload: [String: Any])
    
    @objc optional func handleCommand(_ command: String, with payload: Any?)
    
    @available(*, deprecated, message: "use handleReceivedCommand(_ command: String , data: [String: Any]?) instead")
    @objc optional func handleReceivedCommand(_ command: String, with payload: Any?)
    @objc optional func handleReceivedCommand(_ command: String , data: [String: Any]?)
    
    
    @objc optional func playerPanGesture(state: UIGestureRecognizer.State, position: CGPoint)
    
    @available(*, deprecated, message: "use onEvent(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any]) instead")
    @objc optional func log(name: String, feature: ShopLiveLog.Feature, campaign: String, parameter: [String: String])
    
    @available(*, deprecated, message: "use onEvent(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any]) instead")
    @objc optional func log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any])
    
    @objc optional func onEvent(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any])
    
}
