//
//  ShopLiveBackgroundPosterWebViewInterface.swift
//  ShopLiveSDK
//
//  Created by Tabber on 2/21/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

enum ShopLiveBackgroundPosterWebViewInterface {
    case setBackgroundImageSrc(String)

    var stringValue: String {
        switch self {
        case .setBackgroundImageSrc(let paramter):
            return "setBackgroundImageSrc(\"\(paramter)\")"
        }
    }
}
