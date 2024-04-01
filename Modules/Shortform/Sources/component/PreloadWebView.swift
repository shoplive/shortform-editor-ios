//
//  PreloadWebView.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 3/14/23.
//

import Foundation
import WebKit
import ShopliveSDKCommon


extension ShopLiveShortform {
    class PreloadWebView {
        var webview = SLWebView()
        
        var url: String = ""
        
        func loadWebView() {
            if let url = URL(string: url) {
                var request = URLRequest(url: url)
                request.cachePolicy = .returnCacheDataElseLoad
                webview.load(request)
            }
        }
        
    }
}
