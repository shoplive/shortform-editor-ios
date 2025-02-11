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
        let childContainer = self.container.makeMainSceneDIContainer()
        let coordinator = MainFlowCoordinator(window: self.window, container: childContainer, navigationController: self.navigationController)
        coordinator.start()
    }
    
}
