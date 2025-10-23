//
//  LiveFetchUrlModel.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 9/19/23.
//

import Foundation
import ShopliveSDKCommon


struct LiveFetchUrlModel: BaseResponsable {
    public var _s: Int?
    public var _e: String?
    
    let campaignId: Int
    let liveUrl, previewLiveUrl, videoAspectRatio, campaignStatus, activityType: String?
    let startHorizontalViewOnLandscapeVideo: Bool?
    
    // inApp Pip UI 관련 프로퍼티
    let previewDisplays : PreviewDisplaysModel?
    
    enum CodingKeys: String, CodingKey {
        case _s, _e
        case campaignId = "campaignId"
        case liveUrl = "liveUrl"
        case previewLiveUrl = "previewLiveUrl"
        case videoAspectRatio = "videoAspectRatio"
        case campaignStatus = "campaignStatus"
        case startHorizontalViewOnLandscapeVideo = "startHorizontalViewOnLandscapeVideo"
        case activityType = "activityType"
        case previewDisplays = "previewDisplays"
    }
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        self._s = try parser.parse(targetType: Int.self, key: CodingKeys._s)
        self._e = try parser.parse(targetType: String.self, key: CodingKeys._e)
        self.campaignId = try parser.parse(targetType: Int.self, key: CodingKeys.campaignId) ?? -1
        self.liveUrl = try parser.parse(targetType: String.self, key: CodingKeys.liveUrl)
        self.previewLiveUrl = try parser.parse(targetType: String.self, key: CodingKeys.previewLiveUrl)
        self.videoAspectRatio = try parser.parse(targetType: String.self, key: CodingKeys.videoAspectRatio)
        self.campaignStatus = try parser.parse(targetType: String.self, key: CodingKeys.campaignStatus)
        self.activityType = try parser.parse(targetType: String.self, key: CodingKeys.activityType)
        self.startHorizontalViewOnLandscapeVideo = try parser.parse(targetType: Bool.self, key: CodingKeys.startHorizontalViewOnLandscapeVideo)
        self.previewDisplays = try container.decode(PreviewDisplaysModel.self, forKey: CodingKeys.previewDisplays)
    }
}

