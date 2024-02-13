//
//  Data+extension.swift
//  ShopLiveSDKCommon
//
//  Created by Vincent on 1/25/23.
//

import Foundation

public struct HexEncodingOptions: OptionSet {
    public let rawValue: Int
    static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
}

public extension Data {
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
    
    func convert_SL<T>(to type: T.Type) -> T? where T: Codable {
        do {
            let data = try JSONDecoder().decode(T.self, from: self)
            return data
        } catch {
            //NSLog(error.localizedDescription)
            return nil
        }
    }
}
