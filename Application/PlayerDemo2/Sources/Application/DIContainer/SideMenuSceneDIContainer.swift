//
//  SideMenuSceneDIContainer.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/11/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation


final class SideMenuSceneDIContainer {
    
    private let sDKConfigurationUserDefaults : any AppUserDefaults<SDKConfiguration>
    
    init(sDKConfigurationUserDefaults: any AppUserDefaults<SDKConfiguration>) {
        self.sDKConfigurationUserDefaults = sDKConfigurationUserDefaults
    }
    
    
    func makeOptionSettingSceneDIContainer() -> OptionSettingSceneDIContainer {
        return .init(sDKConfigurationUserDefaults: sDKConfigurationUserDefaults)
    }
    
    func makeSdkConfigurationRepository() -> any OptionSettingRepository<SDKConfiguration> {
        return DefaultOptionSettingRepository(userDefaultsStorage: sDKConfigurationUserDefaults)
    }
    
}
extension SideMenuSceneDIContainer {
    private func makeSideMenuViewModel(routing : SideMenuRouting) -> SideMenuViewModel {
        return .init(routing: routing)
    }
    
    func makeSideMenuNavigationController(routing : SideMenuRouting) -> ShopliveSideMenuNavagation {
        return .init(rootViewController: V2SideMenuViewController(viewModel: makeSideMenuViewModel(routing: routing)))
    }
}
//MARK: - CouponResponseSetting
extension SideMenuSceneDIContainer {
   
    private func makeCouponResponseSettingUseCase() -> CouponResponseSettingUseCase {
        return DefaultCouponResponseSettingUseCase(sdkConfigurationRepository: makeSdkConfigurationRepository(),
                                                   sdkConfigurationMapperUseCase: DefaultSDKConfigurationMapperUseCase())
    }
   
    private func makeCouponResposneSettingViewmodel(routing : CouponResponseRouting) -> CouponResponseSettingViewModel {
        return .init(couponResponseSettingUseCase: makeCouponResponseSettingUseCase(),
                     routing: routing)
    }
    
    func makeCouponResponseSettingViewController(routing : CouponResponseRouting) -> CouponResponseSettingViewController {
        return .init(viewModel: makeCouponResposneSettingViewmodel(routing: routing))
    }
}
