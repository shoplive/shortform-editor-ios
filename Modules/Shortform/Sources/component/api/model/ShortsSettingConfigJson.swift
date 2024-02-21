//
//  ShortsSettingConfigJson.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 3/7/23.
//

import Foundation
import ShopliveSDKCommon

struct ShortsSettingConfigJson: Codable {
    let apiEndpoint: String?
    let shortformApiEndpoint : String?
    let common: ShortsSettingConfigCommon?
    let sdk: ShortsSettingConfigSDK?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        
        self.apiEndpoint = try? parser.parse(targetType: String.self, key: CodingKeys.apiEndpoint)
        self.shortformApiEndpoint = try? parser.parse(targetType: String.self, key: CodingKeys.shortformApiEndpoint)
        self.common = try container.decodeIfPresent(ShortsSettingConfigCommon.self, forKey: .common)
        self.sdk = try container.decodeIfPresent(ShortsSettingConfigSDK.self, forKey: .sdk)
    }
}

struct ShortsSettingConfigCommon: Codable {
    
}

struct ShortsSettingConfigSDK: Codable {
    let detailUrl: String?
    let detailApiInitializeCount: Int?
    let detailApiPaginationCount: Int?
    let listApiInitializeCount: Int?
    let listApiPaginationCount: Int?
    let previewPosition: String?
    let previewMargin: ShortsPreviewMargin?
    let previewMaxSize: CGFloat?
    let previewUseCloseButton: Bool?
    let enabledSwipeOut: Bool?
    let mutedWhenStart : Bool?
    let mixWithOthers : Bool?
    let detailCollectionListAll : Bool?
    let eventTraceEndpoint : String?
    let isCached : Bool?
    let previewRadius : CGFloat?
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.detailUrl = try? parser.parse(targetType: String.self, key: CodingKeys.detailUrl)
        self.detailApiInitializeCount = try? parser.parse(targetType: Int.self, key: CodingKeys.detailApiInitializeCount)
        self.detailApiPaginationCount = try? parser.parse(targetType: Int.self, key: CodingKeys.detailApiPaginationCount)
        self.listApiInitializeCount = try? parser.parse(targetType: Int.self, key: CodingKeys.listApiInitializeCount)
        self.listApiPaginationCount = try? parser.parse(targetType: Int.self, key: CodingKeys.listApiPaginationCount)
        self.previewPosition = try? parser.parse(targetType: String.self, key: CodingKeys.previewPosition)
        self.previewMargin = try container.decodeIfPresent(ShortsPreviewMargin.self, forKey: .previewMargin)
        self.previewMaxSize = try? parser.parse(targetType: CGFloat.self, key: CodingKeys.previewMaxSize)
        self.previewUseCloseButton = try? parser.parse(targetType: Bool.self, key: CodingKeys.previewUseCloseButton)
        self.enabledSwipeOut = try? parser.parse(targetType: Bool.self, key: CodingKeys.enabledSwipeOut)
        self.mutedWhenStart = try? parser.parse(targetType: Bool.self, key: CodingKeys.mutedWhenStart)
        self.mixWithOthers = try? parser.parse(targetType: Bool.self, key: CodingKeys.mixWithOthers)
        self.detailCollectionListAll = try? parser.parse(targetType: Bool.self, key: CodingKeys.detailCollectionListAll)
        self.eventTraceEndpoint = try? parser.parse(targetType: String.self, key: CodingKeys.eventTraceEndpoint)
        self.isCached = try? parser.parse(targetType: Bool.self, key: CodingKeys.isCached)
        self.previewRadius = try? parser.parse(targetType: CGFloat.self, key: CodingKeys.previewRadius)
    }
}

struct ShortsPreviewMargin: Codable {
    let top: CGFloat?
    let left: CGFloat?
    let right: CGFloat?
    let bottom: CGFloat?
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.top = try? parser.parse(targetType: CGFloat.self, key: CodingKeys.top)
        self.left = try? parser.parse(targetType: CGFloat.self, key: CodingKeys.left)
        self.right = try? parser.parse(targetType: CGFloat.self, key: CodingKeys.right)
        self.bottom = try? parser.parse(targetType: CGFloat.self, key: CodingKeys.bottom)
    }
}
