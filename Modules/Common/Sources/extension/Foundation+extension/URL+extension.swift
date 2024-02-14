//
//  URL+extension.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/25/23.
//

import Foundation

public extension URL {
    func withScheme_SL(_ scheme: String) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: false)
        components?.scheme = scheme
        return components?.url
    }
}
