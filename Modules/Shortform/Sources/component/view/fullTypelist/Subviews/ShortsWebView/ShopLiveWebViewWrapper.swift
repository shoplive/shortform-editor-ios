//
//  ShopLiveWebViewWrapper.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 11/18/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon

@objc class ShopLiveWebViewWrapper: NSObject, ShopLiveShortformMessenger {
    
    var view : UIView
    
    init(webView: UIView) {
        self.view = webView
    }
    
    deinit {
//        ShopLiveLogger.memoryLog("[SHOPLIVEWEBVIEWWRAPPER] deinit")
    }
    
    func sendCommandMessage(command : String, payload : [String : Any]) {
        guard let webView = view as? ShortsWebView else { return }
        let jsRequest : ShortsWebView.JSRequest = (.EXTERNAL_COMMAND(command),payload)
        webView.action( .evaluateJavaScript(jsRequest))
    }
}
