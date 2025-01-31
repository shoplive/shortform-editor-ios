//
//  OptionSettingRepository.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/28/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

protocol OptionSettingRepository<DataType> {
    associatedtype DataType
    func saveOptions(data : DataType)
    func getOptions() -> DataType?
}


final class DefaultOptionSettingRepository : OptionSettingRepository {
    typealias DataType = SDKConfiguration
    
    private let userDefaultsStorage : any AppUserDefaults<SDKConfiguration>
    
    
    init(userDefaultsStorage: any AppUserDefaults<SDKConfiguration>) {
        self.userDefaultsStorage = userDefaultsStorage
    }
    
    
    func saveOptions(data: SDKConfiguration) {
        self.userDefaultsStorage.save(data: data)
    }
    
    func getOptions() -> SDKConfiguration? {
        return userDefaultsStorage.get()
    }
}
