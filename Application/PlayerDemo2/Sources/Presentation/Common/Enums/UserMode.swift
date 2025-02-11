//
//  UserMode.swift
//  PlayerDemo2
//
//  Created by Tabber on 2/7/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

enum UserMode: Codable {
    case Guest
    case Common
    case Token
    
    var isGuestMode: Bool {
        switch self {
        case .Guest:
            return true
        case .Common, .Token:
            return false
        }
    }
    
    var useJWT: Bool {
        switch self {
        case .Guest, .Token:
            return true
        case .Common:
            return false
        }
    }
}
