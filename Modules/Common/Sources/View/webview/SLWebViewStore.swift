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
    let dataStore: WKWebsiteDataStore = WKWebsiteDataStore.nonPersistent()
    
    public func updateState() {
        if !ShopLiveUserDefaults.shortFormGuideOpen {
            ShopLiveUserDefaults.shortFormGuideOpen = true
        }
    }
    
}
