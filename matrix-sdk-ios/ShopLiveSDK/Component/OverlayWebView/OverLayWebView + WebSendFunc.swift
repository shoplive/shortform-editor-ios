//
//  OverLayWebView + WebSendFunc.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 11/28/23.
//

import Foundation
import UIKit
import WebKit


extension OverlayWebView {
    
    func sendCommandMessage(command: String, payload: [String : Any]?) {
        guard let payload = payload else {
            return
        }
        
        var message: [String : Any] = [:]
        
        message["command"] = command
        message["payload"] = payload
        
        self.webView?.sendEventToWeb(event: .sendCommandMessage, message.toJson() ?? "", false)
    }
    
    func didCompleteDownloadCoupon(with couponId: String) {
        self.webView?.sendEventToWeb(event: .completeDownloadCoupon, couponId, true)
    }
    
    func didCompleteDownloadCoupon(with couponResult: ShopLiveCouponResult) {
        guard let couponResultJson = couponResult.toJson() else {
            return
        }
        
        self.webView?.sendEventToWeb(event: .downloadCouponResult, couponResultJson)
    }
    
    @available(*, deprecated, message: "use didCompleteDownloadCoupon(with couponResult: ShopLiveCouponResult) instead")
    func didCompleteDownloadCoupon(with couponResult: CouponResult) {
        guard let couponResultJson = couponResult.toJson() else {
            return
        }
        
        self.webView?.sendEventToWeb(event: .downloadCouponResult, couponResultJson)
    }
    
    func didCompleteCustomAction(with customActionResult: ShopLiveCustomActionResult) {
        guard let customActionResultJson = customActionResult.toJson() else {
            return
        }
        
        self.webView?.sendEventToWeb(event: .customActionResult, customActionResultJson)
    }
    
    @available(*, deprecated, message: "use didCompleteCustomAction(with customActionResult: ShopLiveCustomActionResult) instead")
    func didCompleteCustomAction(with customActionResult: CustomActionResult) {
        guard let customActionResultJson = customActionResult.toJson() else {
            return
        }
        
        self.webView?.sendEventToWeb(event: .customActionResult, customActionResultJson)
    }
    
    func didCompleteCustomAction(with id: String) {
        self.webView?.sendEventToWeb(event: .completeCustomAction, id)
    }
    
    func closeWebSocket() {
        ShopLiveBase.sessionState = .terminated
        self.sendEventToWeb(event: .onTerminated)
    }
    
    func sendEventToWeb(event: WebInterface, _ param: Any? = nil, _ wrapping: Bool = false) {
        self.webView?.sendEventToWeb(event: event, param, wrapping)
    }
    
}
