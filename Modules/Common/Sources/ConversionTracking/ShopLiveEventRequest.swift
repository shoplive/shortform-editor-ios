//
//  ShopLiveEventRequest.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 4/11/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation


public struct ShopLiveEventRequest : BaseResponsable {
    public var _e: String?
    public var _s: Int?
    
    public var anonId : String?
    public var custom : String?
    public var env : String?
    public var ceId : String?
    public var idfv : String?
    public var idfa : String?
    public var osType : String?
    public var products : [ShopLiveEventProduct]?
    public var referrer : String?
    public var type : String?
    public var userId : String?
    public var orderId : String?
    public var createdAt : Int?
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self._e = try parser.parse(targetType: String.self, key: CodingKeys._e)
        self._s = try parser.parse(targetType: Int.self, key: CodingKeys._s)
        
        self.anonId = try parser.parse(targetType: String.self, key: CodingKeys.anonId)
        self.custom = try parser.parse(targetType: String.self, key: CodingKeys.custom)
        self.env = try parser.parse(targetType: String.self, key: CodingKeys.env)
        self.ceId = try parser.parse(targetType: String.self, key: CodingKeys.ceId)
        self.idfv = try parser.parse(targetType: String.self, key: CodingKeys.idfv)
        self.idfa = try parser.parse(targetType: String.self, key: CodingKeys.idfa)
        self.osType = try parser.parse(targetType: String.self, key: CodingKeys.osType)
        self.referrer = try parser.parse(targetType: String.self, key: CodingKeys.referrer)
        self.type = try parser.parse(targetType: String.self, key: CodingKeys.type)
        self.userId = try parser.parse(targetType: String.self, key: CodingKeys.userId)
        self.orderId = try parser.parse(targetType: String.self, key: CodingKeys.orderId)
        self.createdAt = try parser.parse(targetType: Int.self, key: CodingKeys.createdAt)
        
        self.products = try container.decodeIfPresent([ShopLiveEventProduct].self, forKey: .products)
    }
}
