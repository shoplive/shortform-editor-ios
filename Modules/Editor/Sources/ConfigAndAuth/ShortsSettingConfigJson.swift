//
//  ShortsSettingConfigJson.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 3/7/23.
//

import Foundation

struct ShortsSettingConfigJson: Codable {
    let apiEndpoint: String?
    let common: ShortsSettingConfigCommon?
    let sdk: ShortsSettingConfigSDK?
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
}

struct ShortsPreviewMargin: Codable {
    let top: CGFloat?
    let left: CGFloat?
    let right: CGFloat?
    let bottom: CGFloat?
}
