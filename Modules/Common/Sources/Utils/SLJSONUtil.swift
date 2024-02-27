//
//  SLJSONUtil.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2/27/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation


public struct SLJSONUtil {
    public static func toJsonString(_ value : Encodable) -> String? {
        do {
            let jsonData = try JSONEncoder().encode(value)
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        }
        catch(_) {
            return nil
        }
    }
}
