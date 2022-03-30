//
//  ShopLiveConfiguration.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/07/11.
//

import Foundation
import UIKit

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

    class AppPreference {
        static var endpoint: String? = nil
        static var landingUrl: String = endpoint ?? ShopLiveDefines.url
        static var appVersion: String? = nil
    }
    
    class SoundPolicy {
        static var keepPlayVideoOnHeadphoneUnplugged: Bool = false
        static var autoResumeVideoOnCallEnded: Bool = false
    }

    class Data {
        static var useLocalStorage: Bool = true
    }
    
    class Indicator {
        static var color: UIColor = .white
        static var isCustomIndicator: Bool {
            return customIndicatorImages.count > 0
        }
        
        static var customIndicatorImages: [UIImage] = []

        static func setLoadingAnimation(images: [UIImage]) {
            customIndicatorImages.removeAll()
            customIndicatorImages.append(contentsOf: images)
        }
    }

    fileprivate override init() {}
}
