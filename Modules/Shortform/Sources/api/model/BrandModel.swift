//
//  BrandModel.swift
//  matrix-shortform-ios
//
//  Created by sangmin han on 2023/05/11.
//

import Foundation
import ShopliveSDKCommon

public struct BrandModel : Codable {
    let id : Int?
    let identifier : String?
    let imageUrl : String?
    let name : String?
    let traceId : String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let parser = SLFlexibleParser(container: container)
        
        self.id = try? parser.parse(targetType: Int.self, key: CodingKeys.id)
        self.identifier = try? parser.parse(targetType: String.self, key: CodingKeys.identifier)
        self.imageUrl = try? parser.parse(targetType: String.self, key: CodingKeys.imageUrl)
        self.name = try? parser.parse(targetType: String.self, key: CodingKeys.name)
        self.traceId = try? parser.parse(targetType: String.self, key: CodingKeys.traceId)
    }
    
}
