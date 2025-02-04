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
        let vc = container.makeOptionSettingViewController(routing: self)
        navigationController?.pushViewController(vc, animated: true)
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

//MARK: - OptionSetting Routing
//TODO: - need to Move inside to some other SubFlowCoordinator
extension AppFlowCoordinator: OptionSettingRouting {
    func showSetPipFloatingOffsetViewController() {
        
    }
    
    func showAddCustomQueryParameterViewController() {
        
    }
    
    func showSetPipPinPositionViewController() {
        
    }
}


//MARK: - Campaigns Routing
extension AppFlowCoordinator: CampaignsRouting {
    func dismissViewController() {
        navigationController?.popViewController(animated: true)
    }
}
