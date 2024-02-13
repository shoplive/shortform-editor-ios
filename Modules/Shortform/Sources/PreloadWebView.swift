//
//  PreloadWebView.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 3/14/23.
//

import Foundation
import WebKit
import ShopLiveSDKCommon


extension ShopLiveShortform {
    class PreloadWebView {
        var webview = SLWebView()
        
        var url: String = ""
        
        
        func loadWebView() {
            if let url = URL(string: url) {
                webview.load(URLRequest(url: url))
            }
        }
    }
}
