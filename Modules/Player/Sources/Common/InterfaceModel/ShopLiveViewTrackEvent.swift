//
//  ShopLiveViewTrackEvent.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 2/6/24.
//

import Foundation


@objc public enum ShopLiveViewTrackEvent : Int, CaseIterable {
    case viewWillDisAppear
    case viewDidDisAppear
    case pipWillAppear
    case pipDidAppear
    case fullScreenWillAppear
    case fullScreenDidAppear
    
    public var name : String {
        switch self {
        case .viewWillDisAppear:
            return "viewWillDisAppear"
        case .viewDidDisAppear:
            return "viewDidDisAppear"
        case .pipWillAppear:
            return "pipWillAppear"
        case .pipDidAppear:
            return "pipDidAppear"
        case .fullScreenWillAppear:
            return "fullScreenWillAppear"
        case .fullScreenDidAppear:
            return "fullScreenDidAppear"
        }
    }
}

@objc public enum ShopLiveViewHiddenActionType : Int {
    case onSwipeOut
    case onBtnTapped
    case onClose
    case onError
    case onRestoringPip
    case onNavigationHandleClose
    
    public var name : String {
        switch self {
        case .onBtnTapped:
            return "onBtnTapped"
        case .onSwipeOut:
            return "onSwipeOut"
        case .onClose:
            return "onClose"
        case .onError:
            return "onError"
        case .onRestoringPip:
            return "onRestoringPip"
        case .onNavigationHandleClose:
            return "onNavigationHandleClose"
        }
    }
    
}
