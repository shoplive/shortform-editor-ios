//
//  ShopLiveConfiguration.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/07/11.
//

import Foundation

protocol SLNotificationName {
    var name: Notification.Name { get }
}

extension RawRepresentable where RawValue == String, Self: SLNotificationName {
    var name: Notification.Name {
        get {
            return Notification.Name(self.rawValue)
        }
    }
}

internal final class ShopLiveConfiguration: NSObject {

    enum SLNotifications: String, SLNotificationName {
        case soundPolicyUpdate
    }

    @objc enum SLPlayControl: Int {
        case none = 0
        case stop
        case pause
        case play
        case resume
    }

    class SoundPolicy {
        static var keepPlayVideoOnHeadphoneUnplugged: Bool = false
        static var autoResumeVideoOnCallEnded: Bool = false
    }

    class Data {
        static var useLocalStorage: Bool = true
    }

    fileprivate override init() {}
}
