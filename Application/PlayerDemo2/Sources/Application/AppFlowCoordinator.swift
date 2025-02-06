//
//  AppFlowCoordinator.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

final class AppFlowCoordinator : NSObject {

    let window: UIWindow?
    private var navigationController: UINavigationController?
    private let container: DIContainer
    
    init(window: UIWindow?, container: DIContainer) {
        self.window = window
        self.navigationController = UINavigationController()
        self.container = container
    }
    
    func start() {
        let vc = container.makeMainViewController(actions: self)
        navigationController?.setViewControllers([vc], animated: false)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
}

//MARK: - Main Routing
extension AppFlowCoordinator: MainRouting {
    
    func showOptionSetting() {
        let childContainer = self.container.makeOptionSettingSceneDIContainer()
        let coordinator = OptionSettingFlowCoordinator(window: self.window, container: childContainer, navigationController: self.navigationController)
        coordinator.start()
    }
    
    func showCouponResponseSetting() { }
    
    func showCampaigns() {
        let vc = container.makeCampaignsViewController(routing: self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showVideoPlayer() { }
    
    func showUserInfo() {
        let vc = container.makeUserInfoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK: - Campaigns Routing
extension AppFlowCoordinator: CampaignsRouting {
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
    }
}
