//
//  ShopliveBridgeInterface + InternalStatic.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 4/16/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import UIKit



extension ShopLiveShortform.BridgeInterface {
    
    
    internal static func isBridgeConnected() -> Bool {
        return Self.shared.webView == nil ? false : true
    }
    
    internal static func sendShortsEvent(event: String, parameter: [String: Any]?) {
        guard isBridgeConnected() else { return }
        Self.shared.onRequestEvaluateJS(command: event, payload: parameter)
    }
    
    internal static func closeShortsDetail(srn : String?) {
        guard isBridgeConnected() else { return }
        var payLoad : [String : Any] = ["isShown": false ]
        if let srn = srn {
            payLoad["srn"] = srn
        }
        Self.shared.onRequestEvaluateJS(command: SdkToWeb.ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN.key, payload: payLoad)
    }
    
    internal static func showShortsDetail(srn : String?) {
        guard isBridgeConnected() else { return }
        var payLoad : [String : Any] = ["isShown": true ]
        if let srn = srn {
            payLoad["srn"] = srn
        }
        Self.shared.onRequestEvaluateJS(command: SdkToWeb.ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN.key, payload: payLoad)
    }
    
    internal static func handleMoveToProductPage(shortsId : String?, srn : String?, product : Product) {
        guard isBridgeConnected() else { return }
        guard let urlString = product.url,
              let productUrl = URL(string: urlString) else { return }
        
        if let webView = Self.shared.webView {
            webView.load(URLRequest(url: productUrl))
            ShopLiveShortform.close()
        }
        
        Self.shared.onRequestEvaluateJS(command: SdkToWeb.ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN.key, payload: ["isShown": false,"srn" : srn ?? ""])
    }
    
    internal static func handleMoveToProductBannerPage(shortsId : String, srn : String, scheme : String, shortsDetail : ShortsDetail) {
        guard isBridgeConnected() else { return }
        guard let url = URL(string: scheme) else { return }
        if let webView = Self.shared.webView {
            webView.load(URLRequest(url: url))
            ShopLiveShortform.close()
        }
        Self.shared.onRequestEvaluateJS(command: SdkToWeb.ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN.key, payload: ["isShown": false, "srn" : srn])
    }
    
    internal static func requestShortsPreview(url : String?, srn : String?) {
        guard isBridgeConnected() else { return }
        guard let url = url,
              let srn = srn else { return }
        
        ShopLiveShortform.close()
        let payload : [String : Any] = ["isShown": false, "srn" : srn ]
        Self.shared.onRequestEvaluateJS(command: SdkToWeb.ON_CHANGED_SHORTFORM_DETAIL_PLAYER_SHOWN.key, payload: payload)
        
        let payload2 : [String : Any] = ["url" : url]
        //안되면 guard let url = webview?.url?.absoluteString else { return } 이걸로 보내야함
        Self.shared.onRequestEvaluateJS(command: SdkToWeb.REQUEST_SHORTFORM_PREVIEW.key, payload: payload2)
    }
    
    internal static func previewShown(shorts : ShortsModel) {
        guard isBridgeConnected() else { return }
        guard let shortsDict = shorts.dictionary_SL else { return }
        let payload: [String: Any] = [
            "shorts": shortsDict
        ]
        Self.shared.onRequestEvaluateJS(command: SdkToWeb.ON_SHORTFORM_PREVIEW_SHOWN.key, payload: payload)
    }
    
    internal static func clickPreview(shorts : ShortsModel) {
        guard isBridgeConnected() else { return }
        guard let shortsDict = shorts.dictionary_SL else { return }
        let payload: [String: Any] = [
            "shorts": shortsDict
        ]
        Self.shared.onRequestEvaluateJS(command: SdkToWeb.ON_CLICK_SHORTFORM_PREVIEW.key, payload: payload)
    }
    
    internal static func previewHidden(shorts : ShortsModel) {
        guard isBridgeConnected() else { return }
        guard let shortsDict = shorts.dictionary_SL else { return }
        let payload: [String: Any] = [
            "shorts": shortsDict
        ]
        Self.shared.onRequestEvaluateJS(command: SdkToWeb.ON_SHORTFORM_PREVIEW_HIDDEN.key, payload: payload)
    }
    
    internal static func previewClose(shorts : ShortsModel) {
        guard isBridgeConnected() else { return }
        guard let shortsDict = shorts.dictionary_SL else { return }
        let payload: [String: Any] = [
            "shorts": shortsDict
        ]
        Self.shared.onRequestEvaluateJS(command: SdkToWeb.ON_CLICK_SHORTFORM_PREVIEW_CLOSE.key, payload: payload)
    }
}
