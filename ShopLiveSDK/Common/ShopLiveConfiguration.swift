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
        
        func getDesc() -> String {
            switch self {
            case .none:
                return "none"
            case .stop:
                return "stop"
            case .pause:
                return "pause"
            case .play:
                return "play"
            case .resume:
                return "resume"
            }
        }
    }
    
    class AppPreference {
        static var endpoint: String? = nil
        static var landingUrl: String {
            endpoint ?? ShopLiveDefines.url
        }
        static var appVersion: String? = nil
    }
    
    class SoundPolicy {
        static var keepPlayVideoOnHeadphoneUnplugged: Bool = false
        static var onHeadphoneUnpluggedIsMute: Bool = false
        static var autoResumeVideoOnCallEnded: Bool = false
        static var isMuted: Bool = false
        static var useMixWithOthers: Bool = false
    }

    class Data {
        #if EBAY
        static var useLocalStorage: Bool = false
        #else
        static var useLocalStorage: Bool = true
        #endif
        static var adid: String?
        
        static var customParameters: [String: String] = [:]
    }
    
    class UI {
        static var pipPadding: UIEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20)
        static var pipFloatingOffset: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
        static var inputBoxFont: UIFont? = nil
        static var sendButtonFont: UIFont? = nil

        static var color: UIColor = .white
        static var isCustomIndicator: Bool {
            return customIndicatorImages.count > 0
        }
        static var customIndicatorImages: [UIImage] = []
        static func setLoadingAnimation(images: [UIImage]) {
            customIndicatorImages.removeAll()
            customIndicatorImages.append(contentsOf: images)
        }

        static var nextActionTypeOnHandleNavigation: ActionType = ActionType.PIP
        static var keepAspectOnTabletPortrait: Bool = true
        
        static var chatInputPlaceholderString: String = "chat.placeholder".localizedString()
        static var chatInputSendString: String = "chat.send.title".localizedString()
        static var chatInputMaxLength: Int = 200
        static var keepWindowStateOnPlayExecuted: Bool = false
        static var keepWindowStyleOnReturnFromOsPip: Bool = false
        
        static var manualRoatation: Bool = false
        static var closeButton: Bool = false
        static var enablePipSwipeOut: Bool = false
    }

    fileprivate override init() {}
}
