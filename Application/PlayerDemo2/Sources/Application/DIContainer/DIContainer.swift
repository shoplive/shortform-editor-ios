//
//  DIContainer.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import ShopliveSDKCommon

final class DIContainer {
    
    // API 연결시 주입해야 함
    init() {
        
    }
    // MARK: - Make ViewController
    func makeMainViewController(actions: MainViewModelActions) -> MainViewController {
        let viewModel = MainViewModel(useCase: makeMainUseCase(),
                                                     actions: actions)
        return MainViewController(viewModel: viewModel)
    }
    
    func makeUserInfoViewController() -> UserInfoViewController {
        let viewModel = UserInfoViewModel(userInfoUseCase: makeUserInfoUseCase())
        return UserInfoViewController(viewModel: viewModel)
    }
    
    // MARK: - Make UseCase
    func makeMainUseCase() -> MainUseCase {
        let repository = DefaultMainRepository()
        return DefaultMainUseCase(mainRepository: repository)
    }
    func makeUserInfoUseCase() -> UserInfoUseCase {
        let repository = DefaultUserInfoRepository()
        return DefaultUserInfoUseCase(repository: repository)
    }
}

