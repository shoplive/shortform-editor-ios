//
//  LinkButton.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 3/19/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon


//youtube 한정
public struct LinkButton : Codable {
    
    var imageUrl : String?
    var text : String?
    var scheme : String?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.imageUrl = try? parser.parse(targetType: String.self, key: CodingKeys.imageUrl)
        self.text = try? parser.parse(targetType: String.self, key: CodingKeys.text)
        self.scheme = try? parser.parse(targetType: String.self, key: CodingKeys.scheme)
    }
    
}

