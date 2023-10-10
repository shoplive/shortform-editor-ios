//
//  LiveFetchUrlModel.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/19/23.
//

import Foundation


struct LiveFetchUrlModel : Codable {
    let campaignId: Int
    let liveUrl, previewLiveUrl, videoAspectRatio, campaignStatus: String?
    let startHorizontalViewOnLandscapeVideo : Bool?
    
    enum CodingKeys: String, CodingKey {
        case campaignId = "campaignId"
        case liveUrl = "liveUrl"
        case previewLiveUrl = "previewLiveUrl"
        case videoAspectRatio = "videoAspectRatio"
        case campaignStatus = "campaignStatus"
        case startHorizontalViewOnLandscapeVideo = "startHorizontalViewOnLandscapeVideo"
    }
}
