//
//  ShopLivePlayerCampaign.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 2/14/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation

@objc public enum ShopLivePlayerCampaignStatus : Int {
    case READY
    case ONAIR
    case CLOSED
    
    public var name : String {
        get {
            switch self {
            case .READY:
                return "READY"
            case .ONAIR:
                return "ONAIR"
            case .CLOSED:
                return "CLOSED"
            }
        }
    }
}

@objc public class ShopLivePlayerCampaign : NSObject {
    @objc public var title : String?
    @objc public var campaignStatus : ShopLivePlayerCampaignStatus = .READY

    @objc public init(title: String? = nil, campaignStatus : ShopLivePlayerCampaignStatus = .READY) {
        self.title = title
        self.campaignStatus = campaignStatus
    }

    internal override init() {
        super.init()
    }

    internal func parse(payload : [String : Any]?) {
        guard let campaignInfo = payload?["campaignInfo"] as? [String : Any] else { return }
        if let campaignTitle = campaignInfo["title"] as? String {
            self.title = campaignTitle
        }
        if let campaignStatus = campaignInfo["campaignStatus"] as? String {
            switch campaignStatus {
            case "READY":
                self.campaignStatus = .READY
            case "ONAIR":
                self.campaignStatus = .ONAIR
            case "CLOSED":
                self.campaignStatus = .CLOSED
            default:
                self.campaignStatus = .READY
            }
           
        }
        
    }
}

