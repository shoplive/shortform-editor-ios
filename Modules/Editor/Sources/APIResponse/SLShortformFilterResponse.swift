//
//  SLShortformFilterResponse.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 2/15/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon


struct SLShortformFilterResponse : BaseResponsable {
    var _s : Int?
    var _e : String?
    let totalCount : Int?
    var results : [Filters]?
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        self._s = try? parser.parse(targetType: Int.self, key: CodingKeys._s)
        self._e = try? parser.parse(targetType: String.self, key: CodingKeys._e)
        self.totalCount = try? parser.parse(targetType: Int.self, key: CodingKeys.totalCount)
        self.results = try? container.decodeIfPresent([Filters].self, forKey: CodingKeys.results)
    }
}

struct Filters : Codable {
    let type : String?
    let title : String?
    let content : String?
    
    init(from decoder: Decoder) throws {
        let container: KeyedDecodingContainer<CodingKeys> = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.type = try? parser.parse(targetType: String.self, key: CodingKeys.type)
        self.title = try? parser.parse(targetType: String.self, key: CodingKeys.title)
        self.content = try? parser.parse(targetType: String.self, key: CodingKeys.content)
    }
    
    init(title : String, content : String,type : String? = nil) {
        self.title = title
        self.content = content
        self.type = type
    }
}
