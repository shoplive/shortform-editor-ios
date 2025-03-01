//
//  PIPFloatingUseCase.swift
//  PlayerDemo2
//
//  Created by sangmin han on 2/5/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation
import UIKit


protocol PIPFloatingUseCase {
    func setPipPaddingInset(inset : UIEdgeInsets)
    func setPipFloatingOffset(inset : UIEdgeInsets)
    
    
    func getPipPaddingInset() -> UIEdgeInsets
    func getPipFloatingOffset() -> UIEdgeInsets
}


final class DefaultPIPFloatingUseCase : PIPFloatingUseCase {
    
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
    
    func setPipPaddingInset(inset: UIEdgeInsets) {
        guard let sdkConfig = sdkConfiguration else { return }
        let newValue = sdkConfigurationMapperUseCase.setValue(by: .pipPadding, to: sdkConfig, value: inset)
        self.sdkConfiguration = newValue
        sdkConfigurationRepository.saveOptions(data: newValue)
    }
    
    func setPipFloatingOffset(inset: UIEdgeInsets) {
        guard let sdkConfig = sdkConfiguration else { return }
        let newValue = sdkConfigurationMapperUseCase.setValue(by: .pipFloatingOffset, to: sdkConfig, value: inset)
        self.sdkConfiguration = newValue
        sdkConfigurationRepository.saveOptions(data: newValue)
    }
    
    func getPipPaddingInset() -> UIEdgeInsets {
        return sdkConfiguration?.pipPadding ?? UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    }
    
    func getPipFloatingOffset() -> UIEdgeInsets {
        return sdkConfiguration?.pipFloatingOffset ?? UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0 )
    }
}

