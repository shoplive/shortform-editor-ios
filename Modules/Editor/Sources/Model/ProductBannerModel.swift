//
//  ProductBannerModel.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 2023/07/27.
//

import Foundation

// MARK: - ProductBanner
struct ProductBanner: Codable {
    let title: String?
    let imageUrl: String?
    let scheme, traceId, type: String?

    enum CodingKeys: String, CodingKey {
        case title
        case imageUrl
        case scheme
        case traceId
        case type
    }
}
