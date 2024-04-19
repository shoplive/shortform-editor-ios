//
//  ShopLivePlayerData.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 11/9/23.
//

import Foundation
import UIKit

public class ShopLivePlayerData : NSObject {
    public var campaignKey : String
    public var keepWindowStateOnPlayExecuted : Bool = true
    public var referrer : String? = nil
    public var campaignHandler : ((ShopLivePlayerCampaign) -> ())?
    public var brandHandler : ((ShopLivePlayerBrand) -> ())?
    public var isMuted : Bool?
    
    
    public init(campaignKey: String, keepWindowStateOnPlayExecuted: Bool = true, referrer: String? = nil,isMuted : Bool? = nil, campaignHandler : ((ShopLivePlayerCampaign) -> ())? = nil, brandHandler : ((ShopLivePlayerBrand) -> ())? = nil) {
        self.campaignKey = campaignKey
        self.keepWindowStateOnPlayExecuted = keepWindowStateOnPlayExecuted
        self.referrer = referrer
        self.campaignHandler = campaignHandler
        self.brandHandler = brandHandler
        self.isMuted = isMuted
    }
}
