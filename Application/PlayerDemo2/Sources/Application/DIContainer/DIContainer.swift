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
    
    private func makeDeepLinkUseCase() -> DeepLinkUseCase {
        return DefaultDeepLinkUseCase(shopLiveKeySetRepository: defaultShopLiveKeySetRepository)
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
// MARK: - MainScene
extension DIContainer {
    func makeMainSceneDIContainer() -> MainSceneDIContainer {
        return .init(defaultShopLiveKeySetRepository: defaultShopLiveKeySetRepository,
                     shopLiveKeySetUserDefaults: makeShopLiveKeySetAppUserDefaults(),
                     appUserDefaults: makeAppUserDefaults())
    }
}
