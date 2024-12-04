//
//  ShopLiveVideoOriginUrlQueryAppender.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 12/4/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation


struct ShopLiveVideoOriginUrlQueryAppender {
    static func appendPreviewQuery(to urlString: String?) -> String? {
        guard let urlString = urlString else {
            return nil
        }
        guard var urlComponents = URLComponents(string: urlString) else {
            return nil
        }

        var queryItems = urlComponents.queryItems ?? []

        if !queryItems.contains(where: { $0.name == "preview" }) {
            queryItems.append(URLQueryItem(name: "preview", value: "1"))
        }

        urlComponents.queryItems = queryItems

        return urlComponents.string
    }
}
