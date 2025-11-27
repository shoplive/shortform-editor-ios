//
//  SLWebViewStore.swift
//  ShopliveSDKCommon
//
//  Created by Tabber on 1/15/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import WebKit
import UIKit

public class SLWebViewStore {
    public static let shared = SLWebViewStore()
    public let dataStore: WKWebsiteDataStore = WKWebsiteDataStore.nonPersistent()
    public let processPool: WKProcessPool = WKProcessPool()
    
    public func updateState() {
        if !ShopLiveUserDefaults.shortFormGuideOpen {
            ShopLiveUserDefaults.shortFormGuideOpen = true
        }
    }
    
}
