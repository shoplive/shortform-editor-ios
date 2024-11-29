//
//  ReferenceByType.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 11/29/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation

public struct ReferenceByType : BaseResponsable, RawDataRepresantable {
    typealias Model = ReferenceByType
    
    public var _s : Int?
    public var _e : String?
    
    public let generalShortformReference : String?
    public let promotionShortformReference : String?
    public let externalShortformReference : String?
    public var rawData: Data?
    
    
    public init(from decoder: Decoder) throws {
        if let userInfoKey = CodingUserInfoKey(rawValue: "rawData") {
            self.rawData = decoder.userInfo[userInfoKey] as? Data
        }
        
        let container: KeyedDecodingContainer<Model.CodingKeys> = try decoder.container(keyedBy: ReferenceByType.CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        
        self._s = try? parser.parse(targetType: Int.self, key: Model.CodingKeys._s)
        self._e = try? parser.parse(targetType: String.self, key: Model.CodingKeys._e)
        
        self.generalShortformReference = try? parser.parse(targetType: String.self, key: Model.CodingKeys.generalShortformReference)
        self.promotionShortformReference = try? parser.parse(targetType: String.self, key: Model.CodingKeys.promotionShortformReference)
        self.externalShortformReference = try? parser.parse(targetType: String.self, key: Model.CodingKeys.externalShortformReference)
    }
    
    public func getRawDataDict() -> [String : Any]? {
        guard let data = rawData else { return nil }
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String : Any]
            return json
        }
        catch(_) {
            return nil
        }
    }
}
