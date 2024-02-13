//
//  ProductModel.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 2023/07/27.
//

import Foundation

struct Product: Codable {
    let brand: String?
    let productId: Int?
    let customerProductId : Int?
    let name: String?
    let description: String?
    let url: String?
    let sku: String?
    let imageUrl: String?
    let currency: String?
    let showPrice: Bool?
    let originalPrice: Double?
    let discountPrice: Double?
    let discountRate: Double?
    let stockStatus: String?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.brand = try container.decodeIfPresent(String.self, forKey: .brand)
        self.productId = try container.decodeIfPresent(Int.self, forKey: .productId)
        self.name = try container.decodeIfPresent(String.self, forKey: .name)
        self.description = try container.decodeIfPresent(String.self, forKey: .description)
        self.url = try container.decodeIfPresent(String.self, forKey: .url)
        self.sku = try container.decodeIfPresent(String.self, forKey: .sku)
        self.imageUrl = try container.decodeIfPresent(String.self, forKey: .imageUrl)
        self.currency = try container.decodeIfPresent(String.self, forKey: .currency)
        self.showPrice = try container.decodeIfPresent(Bool.self, forKey: .showPrice)
        self.originalPrice = try container.decodeIfPresent(Double.self, forKey: .originalPrice)
        self.discountPrice = try container.decodeIfPresent(Double.self, forKey: .discountPrice)
        self.discountRate = try container.decodeIfPresent(Double.self, forKey: .discountRate)
        self.stockStatus = try container.decodeIfPresent(String.self, forKey: .stockStatus)
        self.customerProductId = try container.decodeIfPresent(Int.self, forKey: .customerProductId)
    }
}
