//
//  KeychainData.swift
//  ShopliveCommonLibrary
//
//  Created by James Kim on 2022/11/22.
//

import Foundation

public struct KeychainData: Equatable {
    var service: String
    var account: String
    
    public static func ==(lhs: KeychainData, rhs: KeychainData) -> Bool {
        return lhs.service == rhs.service && lhs.account == rhs.account
    }
}
