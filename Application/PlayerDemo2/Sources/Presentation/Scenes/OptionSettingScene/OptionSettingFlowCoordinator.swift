//
//  OptionSettingFlowCoordinator.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/5/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit




final class OptionSettingFlowCoordinator : NSObject {
    
    let window : UIWindow?
    private var navigationController : UINavigationController?
    private let container : OptionSettingSceneDIContainer
    
    
    init(window : UIWindow?, container : OptionSettingSceneDIContainer, navigationController : UINavigationController?) {
        self.window = window
        self.navigationController = navigationController
        self.container = container
    }
    
    func start() {
        let vc = container.makeOptionSettingViewController(routing: self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
//MARK: - OptionSettingRouting
extension OptionSettingFlowCoordinator : OptionSettingRouting {
    func showSetPipFloatingOffsetViewController() {
        let vc = container.makePipFloatingViewController(routing: self)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func showAddCustomQueryParameterViewController() {
        
    }
    
    func showSetPipPinPositionViewController() {
        
    }
}
extension OptionSettingFlowCoordinator : PIPFloatingOffsetRouting {
    
}
