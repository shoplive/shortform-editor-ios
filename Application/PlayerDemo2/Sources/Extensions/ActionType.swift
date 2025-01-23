//
//  ActionType.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import ShopLiveSDK
import ShopliveSDKCommon

extension ActionType {
    var localizedName: String {
        switch self {
        case .PIP:
            return "sdkoption.nextActionTypeOnNavigation.item1".localized()
        case .KEEP:
            return "sdkoption.nextActionTypeOnNavigation.item2".localized()
        case .CLOSE:
            return "sdkoption.nextActionTypeOnNavigation.item3".localized()
        }
    }
}
