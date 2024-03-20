//
//  ProductBanner.swift
//  ShopLiveShortformSDK
//
//  Created by 김우현 on 5/30/23.
//

import Foundation
import ShopliveSDKCommon


public struct ProductBanner: Codable {
    public let title: String?
    public let imageUrl: String?
    public let scheme, traceId, type: String?

    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.title = try? parser.parse(targetType: String.self, key: CodingKeys.title)
        self.imageUrl = try? parser.parse(targetType: String.self, key: CodingKeys.imageUrl)
        self.scheme = try? parser.parse(targetType: String.self, key: CodingKeys.scheme)
        self.traceId = try? parser.parse(targetType: String.self, key: CodingKeys.traceId)
        self.type = try? parser.parse(targetType: String.self, key: CodingKeys.type)
    }
    
    
    internal func toProductBannerData() -> ProductBannerData {
        var data = ProductBannerData(title: title,imageUrl: imageUrl,scheme: scheme,traceId: traceId,type: type)
        return data
    }
}


@objc public class ProductBannerData : NSObject {
    public var title: String?
    public var imageUrl: String?
    public var scheme, traceId, type: String?
    
    init(title: String? = nil, imageUrl: String? = nil, scheme: String? = nil, traceId: String? = nil, type: String? = nil) {
        self.title = title
        self.imageUrl = imageUrl
        self.scheme = scheme
        self.traceId = traceId
        self.type = type
    }
}
