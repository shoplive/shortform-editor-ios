//
//  SideMenuTypes.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/23/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopLiveSDK

struct SideMenu {
    var identifier: String
    var stringKey: String
}

enum SideMenuTypes: String, CaseIterable {
    case options
    case exit
    case coupon
    case removeCache
//    case removeCache

    var identifier: String {
        return self.rawValue
    }

    var stringKey: String {
        return "menu.\(identifier)"
    }

    var sideMenu: SideMenu {
        return SideMenu(identifier: identifier, stringKey: stringKey)
    }
}

final class ShopLiveSideMenu {
    static var sideMenus: [SideMenu] = [
        SideMenuTypes.options.sideMenu,
        SideMenuTypes.coupon.sideMenu,
        SideMenuTypes.exit.sideMenu,
        SideMenuTypes.removeCache.sideMenu
    ]
}
