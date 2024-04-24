//
//  OverLayWebView + UserImplCallback.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 4/19/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon




extension OverlayWebView {
    func handleUserImplementsCallback(type: String, name : String, param : [String : Any]? ) {
        var passToReceivedCommand : Bool = true
        switch name {
        case "WILL_REDIRECT_CAMPAIGN":
            onWillRedirectCampaign(param: param)
        case "ON_SUCCESS_CAMPAIGN_JOIN":
            onOnSuccessCampaignJoin()
        case "EVENT_LOG":
            passToReceivedCommand = false
            onEventLog(param: param)
        default:
            break
        }
        
        if passToReceivedCommand {
            delegate?.handleReceivedCommand(name, with: param)
        }
    }
    
    
    private func onWillRedirectCampaign(param : [String : Any]?) {
        if let campaignKey: String = param?["ck"] as? String {
            ShopLiveController.shared.campaignKey = campaignKey
        }
    }
    
    private func onOnSuccessCampaignJoin() {
        ShopLiveController.shared.isSuccessCampaignJoin = true
    }
    
    private func onEventLog(param : [String : Any]? ) {
        guard let feature = param?["feature"] as? String,
              let featureType = ShopLiveLog.Feature.featureFrom(type: feature),
              let name = param?["name"] as? String else { return }
        
        var logPayload: [String: Any] = (param?["parameter"] as? [String : Any]) ?? [:]
        var logParameter: [String: String] = [:]
        logPayload.forEach {
            logParameter[$0.key] = "\($0.value)"
        }
        
        let campaignKey: String = (param?["campaignKey"] as? String) ?? ShopLiveController.shared.campaignKey
        
        delegate?.log(name: name, feature: featureType, campaign: campaignKey, payload: logPayload)
        
    }
    
    
}
