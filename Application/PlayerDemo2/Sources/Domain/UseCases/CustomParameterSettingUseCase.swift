//
//  CustomParameterSettingUseCase.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/7/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

protocol CustomParameterSettingUseCase {
    func getCustomParameters() -> [CustomParameter]
    func saveCustomParameters(customParamter : [CustomParameter])
}


final class DefaultCustomParamterSettingUseCase : CustomParameterSettingUseCase {
    
    private let sdkConfigurationRepository : any OptionSettingRepository<SDKConfiguration>
    private let sdkConfigurationMapperUseCase : SDKConfigurationMapperUseCase
    
    private var sdkConfiguration : SDKConfiguration?
    
    init(sdkConfigurationRepository: any OptionSettingRepository<SDKConfiguration>,
         sdkConfigurationMapperUseCase : SDKConfigurationMapperUseCase) {
        self.sdkConfigurationRepository = sdkConfigurationRepository
        self.sdkConfigurationMapperUseCase = sdkConfigurationMapperUseCase
        loadSDKConfiguration()
    }
    
    private func loadSDKConfiguration() {
        self.sdkConfiguration = sdkConfigurationRepository.getOptions()
    }
    
    func getCustomParameters() -> [CustomParameter] {
        guard let sdkConfig = self.sdkConfiguration else {
            return []
        }
        return (sdkConfig.customParamter ?? [:]).enumerated().map { (index, element) -> CustomParameter in
            return .init(customParameterId: index, paramKey: element.key, paramValue: "\(element.value)",isUseParam: true)
        }
    }
    
    func saveCustomParameters(customParamter: [CustomParameter]) {
        guard let sdkConfig = sdkConfiguration else { return }
        let newParam = customParamter
            .filter{ $0.isUseParam }
            .reduce(into: [:]) { dict, item in
                dict[item.paramKey] = item.paramValue
            }
        let newValue = sdkConfigurationMapperUseCase.setValue(by: .addParameter, to: sdkConfig, value: newParam)
        self.sdkConfiguration = newValue
        sdkConfigurationRepository.saveOptions(data: newValue)
    }
}
