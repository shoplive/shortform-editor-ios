//
//  SideMenuFlowCoordinator.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/11/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit

final class SideMenuFlowCoordinator : NSObject {
    
    let window : UIWindow?
    private var navigationController : UINavigationController?
    private let container : SideMenuSceneDIContainer
    private var sideMenuNavigationController : ShopliveSideMenuNavagation?
    
    
    init(window : UIWindow?, container : SideMenuSceneDIContainer, navigationController : UINavigationController?) {
        self.window = window
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let vc = container.makeSideMenuNavigationController(routing: self)
        self.sideMenuNavigationController = vc
        self.sideMenuNavigationController?.sideMenuNavigationDelegate = self
        navigationController?.present(vc, animated: true)
    }
    
}
extension SideMenuFlowCoordinator : ShopliveSideMenuNavagationDelegate {
    func sideMenuNavigationControllDidDismiss() {
        self.sideMenuNavigationController = nil
    }
}
extension SideMenuFlowCoordinator : SideMenuRouting {
    private func dismissSideMenuNavigationController() {
        self.sideMenuNavigationController?.dismiss(animated: true)
        self.sideMenuNavigationController = nil
    }
    func showOptionSettingViewController() {
        dismissSideMenuNavigationController()
        let childContainer = self.container.makeOptionSettingSceneDIContainer()
        let coordinator = OptionSettingFlowCoordinator(window: self.window, container: childContainer, navigationController: self.navigationController)
        coordinator.start()
    }
    
    func showCouponRespondSettingViewController() {
        dismissSideMenuNavigationController()
        let vc = container.makeCouponResponseSettingViewController(routing: self)
        navigationController?.pushViewController(vc, animated: true)
    }
}
extension SideMenuFlowCoordinator : CouponResponseRouting {
    
}
