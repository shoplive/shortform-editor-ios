//
//  MainFlowCoordinator.swift
//  PlayerDemo2
//
//  Created by Tabber on 2/6/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit

final class MainFlowCoordinator : NSObject {
    
    let window: UIWindow?
    private var navigationController: UINavigationController?
    private let container: MainSceneDIContainer
    
    init(window: UIWindow?, container: MainSceneDIContainer, navigationController: UINavigationController?) {
        self.window = window
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let vc = container.makeMainViewController(actions: self)
        navigationController?.setViewControllers([vc], animated: false)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}

extension MainFlowCoordinator: MainRouting {
    func showSideMenuViewController() {
        let childContainer = self.container.makeSideMenuSceneDIContainer()
        let coordinator = SideMenuFlowCoordinator(window: self.window, container: childContainer, navigationController: self.navigationController)
        coordinator.start()
    }
   
    func showCouponResponseSetting() {
    }
    
    func showCampaigns() {
        let vc = container.makeCampaignsViewController(routing: self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showVideoPlayer() {
    }
    
    func showUserInfo() {
        let vc = container.makeUserInfoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension MainFlowCoordinator: CampaignsRouting {
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
    }
}
