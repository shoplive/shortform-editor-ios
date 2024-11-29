//
//  Brand.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 11/29/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation

public struct SLBrandModel : Codable {
    public let id : Int?
    public let identifier : String?
    public let imageUrl : String?
    public let name : String?
    public let traceId : String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let parser = SLFlexibleParser(container: container)
        
        self.id = try? parser.parse(targetType: Int.self, key: CodingKeys.id)
        self.identifier = try? parser.parse(targetType: String.self, key: CodingKeys.identifier)
        self.imageUrl = try? parser.parse(targetType: String.self, key: CodingKeys.imageUrl)
        self.name = try? parser.parse(targetType: String.self, key: CodingKeys.name)
        self.traceId = try? parser.parse(targetType: String.self, key: CodingKeys.traceId)
    }
    
    public func toBrandData() -> BrandData {
        return BrandData(id: id,identifier: identifier,imageUrl: imageUrl,name: name,traceId: traceId)
    }
    
}

@objc public class BrandData : NSObject {
    public var id : Int?
    public var identifier : String?
    public var imageUrl : String?
    public var name : String?
    public var traceId : String?
    
    init(id: Int? = nil, identifier: String? = nil, imageUrl: String? = nil, name: String? = nil, traceId: String? = nil) {
        self.id = id
        self.identifier = identifier
        self.imageUrl = imageUrl
        self.name = name
        self.traceId = traceId
    }
}
