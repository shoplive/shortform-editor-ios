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
    public var previewResolution : ShopLivePlayerPreviewResolution = .PREVIEW
    
    
    public init(
        campaignKey: String,
        keepWindowStateOnPlayExecuted: Bool = true,
        referrer: String? = nil,
        isMuted: Bool? = nil,
        isEnabledVolumeKey: Bool = false,
        resolution: ShopLivePlayerPreviewResolution?,
        campaignHandler: ((ShopLivePlayerCampaign) -> ())? = nil,
        brandHandler: ((ShopLivePlayerBrand) -> ())? = nil
    ) {
        super.init(
            campaignKey: campaignKey,
            keepWindowStateOnPlayExecuted: keepWindowStateOnPlayExecuted,
            referrer: referrer,
            isEnabledVolumeKey: isEnabledVolumeKey,
            campaignHandler: campaignHandler,
            brandHandler: brandHandler
        )
        self.isMuted = isMuted
        if let resolution = resolution {
            self.previewResolution = resolution
        }
    }
}
