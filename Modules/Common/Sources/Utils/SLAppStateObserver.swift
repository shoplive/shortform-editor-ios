//
//  SLAppStateObserver.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 3/22/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
public protocol ShopliveAppStateObserverDelegate: AnyObject {
    func handleAppStateNotification(appState: SLAppState)
}

public enum SLAppState {
    case none
    case orientationDidChange
    case enterLockScreen
    case leaveLockScreen
    case didEnterForeground
    case willEnterForeground
    case didEnterBackground
    case willEnterBackground
}

final public class ShopliveAppStateObserver: NSObject {
    
    public weak var delegate: ShopliveAppStateObserverDelegate?
    
    public override init() {
        super.init()
        self.setupObserver()
    }
    
    deinit {
        teardownAppStateObserver()
    }
    
    private func teardownAppStateObserver() {
        teardownObserver()
        delegate = nil
    }
    
    private func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.protectedDataWillBecomeUnavailableNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: UIApplication.willResignActiveNotification, object: nil)
    }
    
    private func teardownObserver() {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.protectedDataDidBecomeAvailableNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.protectedDataWillBecomeUnavailableNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.didEnterBackgroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willResignActiveNotification, object: nil)
        
    }
    
    @objc private func handleNotification(_ notification: Notification) {
        var appState: SLAppState = .none
        switch notification.name {
        case UIDevice.orientationDidChangeNotification:
            appState = .orientationDidChange
            break
        case UIApplication.protectedDataDidBecomeAvailableNotification:
            appState = .leaveLockScreen
            break
        case UIApplication.protectedDataWillBecomeUnavailableNotification:
            appState = .enterLockScreen
            break
        case UIApplication.didBecomeActiveNotification:
            appState = .didEnterForeground
            break
        case UIApplication.didEnterBackgroundNotification:
            appState = .didEnterBackground
            break
        case UIApplication.willEnterForegroundNotification:
            appState = .willEnterForeground
            break
        case UIApplication.willResignActiveNotification:
            appState = .willEnterBackground
            break
//        case UIScene.willDeactivateNotification:
//            appState = .willEnterBackground
//            break
        default:
            appState = .none
            break
        }
        delegate?.handleAppStateNotification(appState: appState)
    }
    
}
