//
//  AppFlowCoordinator.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit

final class AppFlowCoordinator {

    let window: UIWindow?
    private var navigationController: UINavigationController?
    private let container: DIContainer
    
    init(window: UIWindow?, container: DIContainer) {
        self.window = window
        self.navigationController = UINavigationController()
        self.container = container
    }
    
    func start() {
        let vc = container.makeMainViewController(actions: makeMainActions())
        navigationController?.setViewControllers([vc], animated: false)
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
    
    private func makeMainActions() -> MainViewModelActions {
        return .init(showOptionSetting: {},
                     showCouponResponseSetting: {},
                     showBroadCastList: {},
                     showVideoPlayer: {},
                     showUserInfo: showUserInfo)
    }
    
    private func showUserInfo() {
        let vc = container.makeUserInfoViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}



