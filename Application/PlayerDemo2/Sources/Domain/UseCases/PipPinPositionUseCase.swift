//
//  PipPinPositionUseCase.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/6/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopLiveSDK


protocol PIPPinPositionUseCase {
    func getPIPPinPosition() -> [ShopLive.PipPosition]
    func setPIPPinPosition(pipPosition : ShopLive.PipPosition)
    func setPIPPinPositions(pipPositions : [ShopLive.PipPosition])
}

final class DefaultPIPPinPositionUseCase : PIPPinPositionUseCase {
    
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
    
    func setPIPPinPositions(pipPositions : [ShopLive.PipPosition]) {
        guard let sdkConfig = sdkConfiguration else { return }
        let newValue = sdkConfigurationMapperUseCase.setValue(by: .pipPinPosition, to: sdkConfig, value: pipPositions)
        self.sdkConfiguration = newValue
        sdkConfigurationRepository.saveOptions(data: newValue)
    }
    
    func setPIPPinPosition(pipPosition: ShopLive.PipPosition) {
        guard let sdkConfig = sdkConfiguration else { return }
        var newPipPositions : [ShopLive.PipPosition] = sdkConfig.pipPinPosition ?? [.bottomRight]
        if newPipPositions.contains(where: { $0 == pipPosition }) {
            newPipPositions.removeAll(where: { $0 == pipPosition })
        }
        else {
            newPipPositions.append(pipPosition)
        }
        let newValue = sdkConfigurationMapperUseCase.setValue(by: .pipPinPosition, to: sdkConfig, value: newPipPositions)
        self.sdkConfiguration = newValue
        sdkConfigurationRepository.saveOptions(data: newValue)
    }
    
    func getPIPPinPosition() -> [ShopLive.PipPosition] {
        return sdkConfiguration?.pipPinPosition ?? [.bottomRight]
    }
}

