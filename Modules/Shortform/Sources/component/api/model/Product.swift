//
//  Product.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 2/27/23.
//

import Foundation
import ShopliveSDKCommon

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
    
    
    
    internal func toProductData() -> ProductData {
        var data = ProductData(brand: brand,productId: productId,customerProductId: customerProductId,
                               name: name,descriptions : description,
        url: url,sku: sku,imageUrl: imageUrl, currency: currency,showPrice: showPrice,originalPrice: originalPrice,discountPrice: discountRate,discountRate: discountRate,stockStatus: stockStatus)
        
        return data
    }
}


@objc public class ProductData: NSObject {
    public var brand: String?
    public var productId: String?
    public var customerProductId : String?
    public var name: String?
    public var descriptions: String?
    public var url: String?
    public var sku: String?
    public var imageUrl: String?
    public var currency: String?
    public var showPrice: Bool?
    public var originalPrice: Double?
    public var discountPrice: Double?
    public var discountRate: Double?
    public var stockStatus: String?
    
    init(brand: String? = nil, productId: String? = nil, customerProductId: String? = nil, name: String? = nil, descriptions: String? = nil, url: String? = nil, sku: String? = nil, imageUrl: String? = nil, currency: String? = nil, showPrice: Bool? = nil, originalPrice: Double? = nil, discountPrice: Double? = nil, discountRate: Double? = nil, stockStatus: String? = nil) {
        self.brand = brand
        self.productId = productId
        self.customerProductId = customerProductId
        self.name = name
        self.descriptions = descriptions
        self.url = url
        self.sku = sku
        self.imageUrl = imageUrl
        self.currency = currency
        self.showPrice = showPrice
        self.originalPrice = originalPrice
        self.discountPrice = discountPrice
        self.discountRate = discountRate
        self.stockStatus = stockStatus
    }
}
