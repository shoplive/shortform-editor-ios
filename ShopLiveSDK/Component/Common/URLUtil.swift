//
//  URLUtil.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2022/03/29.
//

import Foundation

final class URLUtil {

    static func query(_ params: [URLQueryItem]?) -> String? {
        guard let params = params else { return nil }
        let queryStr = params.compactMap({ (param) -> String in
            var value: String = ""
            if let val = param.value {
                value = val.urlEncodedStringRFC3986 ?? val
            }
            return "\(param.name)=\(value)"

        }).joined(separator: "&")
        return queryStr
    }

}
