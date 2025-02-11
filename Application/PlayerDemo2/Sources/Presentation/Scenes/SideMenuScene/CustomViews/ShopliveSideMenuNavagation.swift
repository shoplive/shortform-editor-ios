//
//  ShopliveSideMenuNavagation.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
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

