//
//  Dictionary+extension.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation

public extension Dictionary {
    func toJson_SL() -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [])
        if let jsonString = String(data: jsonData!, encoding: .utf8){
            return jsonString
        }else{
            return nil
        }
    }
    
    var jsonData_SL: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
    }
    
    func toJSONString_SL() -> String? {
        if let jsonData = jsonData_SL {
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        }
        
        return nil
    }
}
