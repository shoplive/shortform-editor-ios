//
//  ShortsDetail.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 2023/07/27.
//

import Foundation

struct ShortsDetail : Codable {
    let title : String?
    let description : String?
//    let author : Author?
    let tags : [String]?
    let productCount : Int?
    let productBanner: ProductBanner?
    let products : [Product]?
    let brand : BrandModel?

    enum CodingKeys: String, CodingKey {
        case title = "title"
        case description = "description"
//        case author = "author"
        case productBanner
        case tags = "tags"
        case productCount = "productCount"
        case products = "products"
        case brand = "brand"
    }
    
}
