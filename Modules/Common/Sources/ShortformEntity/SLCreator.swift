//
//  Creator.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 11/29/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
//youtube 한정
public struct SLCreator: Codable {
    
    var uid: String?
    var userId: String?
    var displayUserId: String?
    var customerCreatorType: String?
    
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self.uid = try? parser.parse(targetType: String.self, key: CodingKeys.uid)
        self.userId = try? parser.parse(targetType: String.self, key: CodingKeys.userId)
        self.displayUserId = try? parser.parse(targetType: String.self, key: CodingKeys.displayUserId)
        self.customerCreatorType = try? parser.parse(targetType: String.self, key: CodingKeys.customerCreatorType)
    }
    
}
