//
//  URLUtil.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/07/31.
//

import Foundation
public final class URLUtil_SL {
    public static func query(_ params: [URLQueryItem]?) -> String? {
        guard let params = params else { return nil }
        let queryStr = params.compactMap({ (param) -> String in
            var value: String = ""
            if let val = param.value {
                value = val.urlEncodedStringRFC3986_SL ?? val
            }
            return "\(param.name)=\(value)"

        }).joined(separator: "&")
        return queryStr
    }

}
