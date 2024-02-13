//
//  BrandModel.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 2023/07/27.
//

import Foundation

public struct BrandModel : Codable {
    let id : Int?
    let identifier : String?
    let imageUrl : String?
    let name : String?
    let traceId : String?
    
    enum CodingKeys : String, CodingKey {
        case id = "id"
        case identifier = "identifier"
        case imageUrl = "imageUrl"
        case name = "name"
        case traceId = "traceId"
    }
    
    
}
