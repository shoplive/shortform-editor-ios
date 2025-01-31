//
//  AppUserDefaults.swift
//  PlayerDemo2
//
//  Created by sangmin han on 1/28/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

protocol AppUserDefaults<DataType> {
    associatedtype DataType
    var suiteName : String { get }
    var userDefaults : UserDefaults? { get }
    
    func save(data : DataType)
    func get() -> DataType?
    
    init(suiteName : String)
}
