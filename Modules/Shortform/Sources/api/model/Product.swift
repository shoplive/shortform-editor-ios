//
//  Product.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/27/23.
//

import Foundation
import ShopLiveSDKCommon

public struct Product: Codable {
    public let brand: String?
    public let productId: String?
    public let customerProductId : String?
    public let name: String?
    public let description: String?
    public let url: String?
    public let sku: String?
    public let imageUrl: String?
    public let currency: String?
    public let showPrice: Bool?
    public let originalPrice: Double?
    public let discountPrice: Double?
    public let discountRate: Double?
    public let stockStatus: String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.brand = try? parser.parse(targetType: String.self, key: CodingKeys.brand)
        self.productId = try? parser.parse(targetType: String.self, key: CodingKeys.productId)
        self.name = try? parser.parse(targetType: String.self, key: CodingKeys.name)
        self.description = try? parser.parse(targetType: String.self, key: CodingKeys.description)
        self.url = try? parser.parse(targetType: String.self, key: CodingKeys.url)
        self.sku = try? parser.parse(targetType: String.self, key: CodingKeys.sku)
        self.imageUrl = try? parser.parse(targetType: String.self, key: CodingKeys.imageUrl)
        self.currency = try? parser.parse(targetType: String.self, key: CodingKeys.currency)
        self.showPrice = try? parser.parse(targetType: Bool.self, key: CodingKeys.showPrice)
        self.originalPrice = try? parser.parse(targetType: Double.self, key: CodingKeys.originalPrice)
        self.discountPrice = try? parser.parse(targetType: Double.self, key: CodingKeys.discountPrice)
        self.discountRate = try? parser.parse(targetType: Double.self, key: CodingKeys.discountRate)
        self.stockStatus = try? parser.parse(targetType: String.self, key: CodingKeys.stockStatus)
        self.customerProductId = try? parser.parse(targetType: String.self, key: CodingKeys.customerProductId)
    }
}

