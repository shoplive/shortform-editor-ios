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
    
    
    lazy var defaultShopLiveKeySetRepository = DefaultShopLiveKeySetRepository(shopLiveKeySetStorage: makeShopLiveKeySetAppUserDefaults())
    
    // API 연결시 주입해야 함
    init() {
       //setInitialUserDefaultsData
        let appUserDefaults = makeAppUserDefaults()
        if appUserDefaults.get() == nil {
            appUserDefaults.save(data: SDKConfiguration(isGuestMode: false,
                                                        useJWTToken: false,
                                                        stopVideoOnHeadphoneDisconnected: false,
                                                        muteVideoOnHeadphoneDisconnected: false,
                                                        useCallOption: false,
                                                        useCustomShare: false,
                                                        useCustomProgress: false,
                                                        useCustomChatInputFont: false,
                                                        useCustomChatSendButtonFont: false,
                                                        pipPadding: .init(top: 20, left: 20, bottom: 20, right: 20),
                                                        pipFloatingOffset: .init(top: 20, left: 20, bottom: 20, right: 20),
                                                        pipEnableSwipeOut: true,
                                                        enablePip: true,
                                                        enableOSPip: true,
                                                        usePlayWhenPreviewTapped: true,
                                                        useInAppPipCloseButton: true,
                                                        isMuted: false,
                                                        enablePreviewSound: false,
                                                        isEnabledVolumeKey: true,
                                                        useKeepWindowStateOnPlayExecuted: false,
                                                        usePipKeepWindowStyle: false,
                                                        useManualRotation: false,
                                                        useMixAudio: false,
                                                        statusBarVisibility: true,
                                                        resizeMode: .CENTER_CROP,
                                                        previewResolution: .LIVE))
        }
        let shopLiveKeySetAppUserDefaults = makeShopLiveKeySetAppUserDefaults()
        if shopLiveKeySetAppUserDefaults.get() == nil {
            shopLiveKeySetAppUserDefaults.save(data: .init(currentSelectKey: "", shopLiveKetSets: []))
        }
        
        DeepLinkManager.shared.deepLinkUseCase = makeDeepLinkUseCase()
    }
    
    private func makeSDKConfigurationMapperUseCase() -> SDKConfigurationMapperUseCase {
        return DefaultSDKConfigurationMapperUseCase()
    }
    
    // MARK: - Make ViewController
    func makeMainViewController(actions: MainRouting) -> MainViewController {
        let viewModel = MainViewModel(useCase: makeMainUseCase(),
                                                     actions: actions)
        return MainViewController(viewModel: viewModel)
    }
    
    func makeUserInfoViewController() -> UserInfoViewController {
        let viewModel = UserInfoViewModel(userInfoUseCase: makeUserInfoUseCase())
        return UserInfoViewController(viewModel: viewModel)
    }
    
    func makeCampaignsViewController(routing: CampaignsRouting) -> CampaignsViewController {
        let viewModel = CampaignsViewModel(useCase: makeCampaignsUseCase(), routing: routing)
        return CampaignsViewController(viewModel: viewModel)
    }
    
    // MARK: - Make UseCase
    private func makeMainUseCase() -> MainUseCase {
        return DefaultMainUseCase(shopLiveKeySetRepository: defaultShopLiveKeySetRepository)
    }
    
    private func makeDeepLinkUseCase() -> DeepLinkUseCase {
        return DefaultDeepLinkUseCase(shopLiveKeySetRepository: defaultShopLiveKeySetRepository)
    }
    
    private func makeUserInfoUseCase() -> UserInfoUseCase {
        let repository = DefaultUserInfoRepository()
        return DefaultUserInfoUseCase(repository: repository)
    }
    private func makeCampaignsUseCase() -> CampaignsUseCase {
        let repository = DefaultCampaignsRepository(userDefaultsStorage: makeShopLiveKeySetAppUserDefaults())
        return DefaultCampaignsUseCase(campaignsRepository: repository)
    }
}
//MARK: - Persistance Storage
extension DIContainer {
    func makeAppUserDefaults() -> any AppUserDefaults<SDKConfiguration> {
        return DefaultAppUserDefaults(suiteName: "Demo.PlayerDemo2")
    }
    func makeShopLiveKeySetAppUserDefaults() -> any AppUserDefaults<ShopLiveCampaignsKey> {
        return DefaultShopLiveKeySetAppUserDefaults(suiteName: "Demo.PlayerDemo2.ShopLiveKeySet")
    }
}
//MARK: - OptionSettingView
extension DIContainer {
    
    private func makeOptionSettingRepository() -> any OptionSettingRepository<SDKConfiguration> {
        return DefaultOptionSettingRepository(userDefaultsStorage: makeAppUserDefaults())
    }
    
    private func makeOptionSettingUseCase() -> any OptionSettingUseCase {
        return DefaultOptionSettingUseCase(optionSettingRepository: makeOptionSettingRepository())
    }

    
    private func makeOptionSettingViewModel(routing : OptionSettingRouting) -> OptionSettingViewModel {
        return .init(optionSettingUseCase: makeOptionSettingUseCase(),
                     sdkConfigureMapperUseCase: makeSDKConfigurationMapperUseCase(),
                     routing: routing)
    }
    
    func makeOptionSettingViewController(routing : OptionSettingRouting) -> V2OptionSettingViewController {
        return .init(viewModel: makeOptionSettingViewModel(routing: routing))
    }
}
