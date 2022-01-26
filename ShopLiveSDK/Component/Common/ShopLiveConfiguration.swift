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
        var keepPlayVideoOnHeadphoneUnplugged: Bool = false {
            willSet {
                guard keepPlayVideoOnHeadphoneUnplugged != newValue else { return }
                updateNotification()
            }
        }

        var autoResumeVideoOnCallEnded: Bool = true {
            willSet {
                guard autoResumeVideoOnCallEnded != newValue else { return }
                updateNotification()
            }
        }

        private func updateNotification() {
            NotificationCenter.default.post(name: SLNotifications.soundPolicyUpdate.name, object: nil)
        }
    }

    static var soundPolicy: SoundPolicy = .init()

    fileprivate override init() {}
}
