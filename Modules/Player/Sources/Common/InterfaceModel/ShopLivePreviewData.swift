//
//  ShopLivePlayerPreviewData.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 5/14/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit

public class ShopLivePreviewData : ShopLivePlayerData {
    public var isMuted : Bool?
    
    public init(campaignKey: String, keepWindowStateOnPlayExecuted: Bool = true, referrer: String? = nil,isMuted : Bool? = nil, campaignHandler : ((ShopLivePlayerCampaign) -> ())? = nil, brandHandler : ((ShopLivePlayerBrand) -> ())? = nil) {
        super.init(campaignKey: campaignKey,keepWindowStateOnPlayExecuted: keepWindowStateOnPlayExecuted,referrer: referrer, campaignHandler: campaignHandler, brandHandler: brandHandler )
        self.isMuted = isMuted
    }
}
