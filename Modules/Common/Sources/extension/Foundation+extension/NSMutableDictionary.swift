//
//  NSMutableDictionary.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation

public extension NSMutableDictionary {
    func toJson_SL() -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [])
        if let jsonString = String(data: jsonData!, encoding: .utf8) {
            return jsonString
        } else{
            return nil
        }
    }
}
