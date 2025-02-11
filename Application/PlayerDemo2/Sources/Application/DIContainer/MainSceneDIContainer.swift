//
//  MainSceneDIContainer.swift
//  PlayerDemo2
//
//  Created by Tabber on 2/6/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

final class MainSceneDIContainer {
    
    private var defaultShopLiveKeySetRepository: ShopLiveKeySetRepository
    private var shopLiveKeySetUserDefaults: any AppUserDefaults<ShopLiveCampaignsKey>
    private var appUserDefaults: any AppUserDefaults<SDKConfiguration>
    
    private lazy var userInfoRepository = DefaultUserInfoRepository(userDefaultsStorage: appUserDefaults)
    
    init(defaultShopLiveKeySetRepository: ShopLiveKeySetRepository,
         shopLiveKeySetUserDefaults: any AppUserDefaults<ShopLiveCampaignsKey>,
         appUserDefaults: any AppUserDefaults<SDKConfiguration>
    ) {
        self.defaultShopLiveKeySetRepository = defaultShopLiveKeySetRepository
        self.shopLiveKeySetUserDefaults = shopLiveKeySetUserDefaults
        self.appUserDefaults = appUserDefaults
    }
}

// MARK: - MainView
extension MainSceneDIContainer {
    func makeMainViewController(actions: MainRouting) -> MainViewController {
        let viewModel = MainViewModel(useCase: makeMainUseCase(),
                                                     actions: actions)
        return MainViewController(viewModel: viewModel)
    }

    private func makeMainUseCase() -> MainUseCase {
        return DefaultMainUseCase(shopLiveKeySetRepository: defaultShopLiveKeySetRepository,
                                  userInfoRepository: userInfoRepository)
    }
}

// MARK: - CampaignsView
extension MainSceneDIContainer {
    func makeCampaignsViewController(routing: CampaignsRouting) -> CampaignsViewController {
        let viewModel = CampaignsViewModel(useCase: makeCampaignsUseCase(), routing: routing)
        return CampaignsViewController(viewModel: viewModel)
    }
    
    private func makeCampaignsUseCase() -> CampaignsUseCase {
        let repository = DefaultCampaignsRepository(userDefaultsStorage: shopLiveKeySetUserDefaults)
        return DefaultCampaignsUseCase(campaignsRepository: repository)
    }
}

// MARK: - UserInfoView
extension MainSceneDIContainer {
    
    func makeUserInfoViewController() -> UserInfoViewController {
        let viewModel = UserInfoViewModel(userInfoUseCase: makeUserInfoUseCase())
        return UserInfoViewController(viewModel: viewModel)
    }
    
    private func makeUserInfoUseCase() -> UserInfoUseCase {
        return DefaultUserInfoUseCase(userInfoRepository: userInfoRepository)
    }
    
}

//MARK: - OptionSettingScene
extension MainSceneDIContainer {
    func makeOptionSettingSceneDIContainer() -> OptionSettingSceneDIContainer {
        return .init(sDKConfigurationUserDefaults: appUserDefaults)
    }
}
