//
//  OptionSettingUseCase.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/28/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

protocol OptionSettingUseCase {
    func saveOptions(data : SDKConfiguration)
    func getOptions() -> SDKConfiguration?
}


final class DefaultOptionSettingUseCase : OptionSettingUseCase {
    private let optionSettingRepository : any OptionSettingRepository<SDKConfiguration>
    
    init(optionSettingRepository: any OptionSettingRepository<SDKConfiguration>) {
        self.optionSettingRepository = optionSettingRepository
    }
    
    func saveOptions(data : SDKConfiguration) {
        optionSettingRepository.saveOptions(data: data)
    }
    
    func getOptions() -> SDKConfiguration? {
        return optionSettingRepository.getOptions()
    }
}
