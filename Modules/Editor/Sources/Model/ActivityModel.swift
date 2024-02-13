//
//  ActivityModel.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 2023/07/27.
//

import Foundation
struct Activity: Codable {
    let viewCount, likeCount, commentCount, bookmarkCount: Int?
    let like, bookmark: Bool?
}
