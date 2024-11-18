//
//  ShopLiveWebViewWrapper.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 11/18/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit

@objc public class ShopLiveWebViewWrapper: NSObject {
    
    public let webView : UIView
    
    init(webView: UIView) {
        self.webView = webView
    }
    
    deinit {
        print("ShopLiveWebViewWrapper deinit")
    }
    
    public func evaluateJavaScript(command : String, payload : [String : Any]) {
        guard let webView = webView as? ShortsWebView else { return }
        let jsRequest : ShortsWebView.JSRequest = (.EXTERNAL_COMMAND(command),payload)
        webView.action( .evaluateJavaScript(jsRequest))
    }
}
