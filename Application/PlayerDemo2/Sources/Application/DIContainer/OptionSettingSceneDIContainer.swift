//
//  OptionSettingSceneDIContainer.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/5/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation


final class OptionSettingSceneDIContainer {
    
    private let sDKConfigurationUserDefaults : any AppUserDefaults<SDKConfiguration>
    
    init(sDKConfigurationUserDefaults: any AppUserDefaults<SDKConfiguration>) {
        self.sDKConfigurationUserDefaults = sDKConfigurationUserDefaults
    }
    
    
    private func makeSDKConfigurationMapperUseCase() -> SDKConfigurationMapperUseCase {
        return DefaultSDKConfigurationMapperUseCase()
    }
}
//MARK: - OptionSettingView
extension OptionSettingSceneDIContainer {
    private func makeOptionSettingRepository() -> any OptionSettingRepository<SDKConfiguration> {
        return DefaultOptionSettingRepository(userDefaultsStorage: sDKConfigurationUserDefaults)
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
//MARK: - PIPFloatingView
extension OptionSettingSceneDIContainer {
    private func makePipFloatingUseCase() -> any PIPFloatingUseCase {
        return DefaultPIPFloatingUseCase(sdkConfigurationRepository: makeOptionSettingRepository(),
                                         sdkConfigurationMapperUseCase: makeSDKConfigurationMapperUseCase())
    }
    
    private func makePipFloatingViewModel(routing : PIPFloatingOffsetRouting) -> PIPFloatingOffsetViewModel {
        return .init(pipFloatingOffsetUseCase: makePipFloatingUseCase(),
                     routing: routing)
    }
    
    func makePipFloatingViewController(routing : PIPFloatingOffsetRouting) -> PIPFloatingOffsetViewController {
        return .init(viewModel: makePipFloatingViewModel(routing: routing))
    }
}
//MARK: - PIPPinPositionView
extension OptionSettingSceneDIContainer {
    
    
    private func makePipPinPositionUseCase() -> PIPPinPositionUseCase {
        return DefaultPIPPinPositionUseCase(sdkConfigurationRepository: makeOptionSettingRepository(),
                                            sdkConfigurationMapperUseCase: makeSDKConfigurationMapperUseCase())
    }
    
    private func makePipPinPositionViewModel(routing : PipPinPositionRouting) -> PIPPinPositionViewModel {
        return .init(useCase: makePipPinPositionUseCase(),
                     routing: routing)
    }
    
    func makePipPinPositionViewController(routing : PipPinPositionRouting) -> PipPinPositionSettingsViewController {
        return .init(viewModel: makePipPinPositionViewModel(routing: routing))
    }
}
