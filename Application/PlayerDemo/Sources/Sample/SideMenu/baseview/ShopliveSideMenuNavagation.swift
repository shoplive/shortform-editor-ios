//
//  ShopliveSideMenuNavagation.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import Foundation
import UIKit
import SideMenu

class ShopliveSideMenuNavagation: SideMenuNavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.presentationStyle = .menuSlideIn
        self.leftSide = true
        self.statusBarEndAlpha = 0.0
        self.menuWidth = 280
        self.presentationStyle.presentingEndAlpha = 0.5
    }
}
