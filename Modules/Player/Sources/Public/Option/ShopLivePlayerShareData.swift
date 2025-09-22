//
//  ShopLivePlayerShareData.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 1/30/24.
//

import Foundation

///공유하기 시, shareDelegate를 통해 커스텀 공유팝업을 위한 데이터
@objc public class ShopLivePlayerShareData: NSObject {
    @objc public let campaign: ShopLivePlayerShareCampaign?
    @objc public let url: String?
    
    internal init(campaign: ShopLivePlayerShareCampaign?, url: String?) {
        self.campaign = campaign
        self.url = url
    }
}

///공유하기 시, shareDelegate를 통해 커스텀 공유팝업을 위한 캠페인 정보
@objc public class ShopLivePlayerShareCampaign: NSObject {
    @objc public let campaignKey: String?
    @objc public let title: String?
    @objc public let descriptions: String?
    @objc public let thumbnail: String?
    
    internal init(payload: [String: Any]) {
        self.campaignKey = payload["campaignKey"] as? String
        let campaignDict = payload["campaign"] as? [String: Any]
        self.title = campaignDict?["title"] as? String
        self.descriptions = campaignDict?["description"] as? String
        self.thumbnail = campaignDict?["posterUrl"] as? String
    }
}
