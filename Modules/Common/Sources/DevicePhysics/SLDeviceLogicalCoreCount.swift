//
//  SLDeviceLogicalCore.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 12/18/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation



public struct SLDeviceLogicalCoreCount {
    // 기기별 논리 코어 개수
    private static let deviceCores: [String: Int] = [
        "iPhone SE (1st Gen)": 2,
        "iPhone 7": 2,
        "iPhone 7 Plus": 4,
        "iPhone 8": 6,
        "iPhone 8 Plus": 6,
        "iPhone X": 6,
        "iPhone 11": 6,
        "iPhone 11 Pro": 6,
        "iPhone 12": 6,
        "iPhone 13": 6,
        "iPhone 14": 6,
        "iPhone 15": 6,
        "iPad (7th Gen)": 4,
        "iPad Air (3rd Gen)": 6,
        "iPad Pro (2020, 11\")": 8,
        "iPad Pro (2021, M1)": 8,
        "iPad Pro (2022, M2)": 8,
        "MacBook Air (M1)": 8,
        "MacBook Pro (M1 Pro)": 10,
        "MacBook Pro (M2 Pro)": 10,
        "Mac Studio (M1 Ultra)": 20
    ]
    
    // 현재 기기의 논리 코어 수 가져오기
    public static func currentDeviceCoreCount() -> Int? {
        let deviceName = self.currentDeviceName()
        return deviceCores[deviceName]
    }
    
    // 현재 기기 이름 가져오기
    private static func currentDeviceName() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.compactMap { $0.value as? Int8 }
            .map { String(UnicodeScalar(UInt8($0))) }
            .joined()
        return mapToDevice(identifier: identifier)
    }
    
    // Identifier를 기기 이름으로 매핑
    private static func mapToDevice(identifier: String) -> String {
        // 간단한 예제. 실제 프로젝트에서는 모든 identifier를 매핑해야 함.
        switch identifier {
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone13,4": return "iPhone 12"
        case "iPad11,3": return "iPad Air (3rd Gen)"
        case "iPad13,4": return "iPad Pro (2021, M1)"
        case "MacBookAir10,1": return "MacBook Air (M1)"
        default: return "Unknown Device"
        }
    }
}
