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
    
    public init(campaignKey: String, keepWindowStateOnPlayExecuted: Bool = true, referrer: String? = nil) {
        self.campaignKey = campaignKey
        self.keepWindowStateOnPlayExecuted = keepWindowStateOnPlayExecuted
        self.referrer = referrer
    }
}
