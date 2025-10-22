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

struct PreviewDisplaysModel: Codable {
    let badge: PreviewBadgeModel
    let textBox: PreviewTextBoxModel
    
    enum CodingKeys: CodingKey {
        case badge
        case textBox
    }
    
    func toEntity() -> InAppPipDisplaysModel {
        .init(
            badge: badge.active ? badge.toEntity() : nil,
            textBox: textBox.active ? textBox.toEntity() : nil
        )
    }
}

struct PreviewBadgeModel: Codable {
    let active: Bool
    let imageUrl: String?
    let layout: PreviewLayoutModel
    let size: PreviewSizeModel
    
    func toEntity() -> InAppPipDisplayModel {
        .init(
            type: "BADGE",
            active: active,
            layout: layout.toAlignmentEntity(),
            padding: layout.toPaddingEntity(),
            size: size.toEntity(),
            imageUrl: imageUrl
        )
    }
}

struct PreviewLayoutModel: Codable {
    let padding: PreviewPaddingModel
    let alignment: PreviewAlignmentModel
    
    func toPaddingEntity() -> InAppPipDisplayPadding {
        .init(
            horizontal: CGFloat(padding.horizontal),
            vertical: CGFloat(padding.vertical)
        )
    }
    
    func toAlignmentEntity() -> InAppPipDisplayLayout {
        .init(
            horizontal: alignment.horizontal,
            vertical: alignment.vertical
        )
    }
}

struct PreviewPaddingModel: Codable {
    let horizontal: Int
    let vertical: Int
}

struct PreviewAlignmentModel: Codable {
    let horizontal: String
    let vertical: String
}

struct PreviewSizeModel: Codable {
    let width: Int
    let height: Int
    let maxWidth: Int
    
    func toEntity() -> InAppPipDisplaySize {
        .init(
            width: CGFloat(width),
            height: CGFloat(height),
            maxWidth: CGFloat(maxWidth)
        )
    }
}

struct PreviewTextBoxModel: Codable {
    let active: Bool
    let text: String?
    let layout: PreviewLayoutModel
    let box: PreviewBoxModel
    let font: PreviewFontModel
    
    func toEntity() -> InAppPipDisplayModel {
        .init(
            type: "TEXTBOX",
            active: active,
            layout: layout.toAlignmentEntity(),
            padding: layout.toPaddingEntity(),
            size: nil,
            imageUrl: nil,
            text: text,
            font: font.toEntity(),
            box: box.toEntity()
        )
    }
}

struct PreviewBoxModel: Codable {
    let backgroundColor: String
    let borderRadius: Int
    let paddingX: Int
    let paddingY: Int
    
    func toEntity() -> InAppDisplayBox {
        .init(
            backgroundColor: backgroundColor,
            borderRadius: CGFloat(borderRadius),
            paddingX: CGFloat(paddingX),
            paddingY: CGFloat(paddingY)
        )
    }
}

struct PreviewFontModel: Codable {
    let size: Int
    let color: String
    
    func toEntity() -> InAppPipDisplayFont {
        .init(
            size: CGFloat(size),
            color: color
        )
    }
}
