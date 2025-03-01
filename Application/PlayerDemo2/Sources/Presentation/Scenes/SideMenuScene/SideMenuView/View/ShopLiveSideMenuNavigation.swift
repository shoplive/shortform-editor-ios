//
//  ShopLiveSideMenuNavigation.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/12/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import SideMenu

protocol ShopliveSideMenuNavagationDelegate : NSObjectProtocol {
    func sideMenuNavigationControllDidDismiss()
}

class ShopliveSideMenuNavagation: SideMenuNavigationController {

    
    weak var sideMenuNavigationDelegate : ShopliveSideMenuNavagationDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.presentationStyle = .menuSlideIn
        self.leftSide = true
        self.statusBarEndAlpha = 0.0
        self.menuWidth = 280
        self.presentationStyle.presentingEndAlpha = 0.5
    }
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sideMenuNavigationDelegate?.sideMenuNavigationControllDidDismiss()
    }
}
