//
//  ShopLiveLog.swift
//  ShopLiveSDK
//
//  Created by yong C on 8/6/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

@objc public class ShopLiveLog: NSObject {
    @objc public enum Feature: Int, CaseIterable {
        case CLICK, SHOW, ACTION
        
        public var name: String {
            switch self {
            case .CLICK:
                return "click"
            case .ACTION:
                return "action"
            case .SHOW:
                return "show"
            }
        }
        
        static func featureFrom(type: String) -> Feature? {
            return Feature.allCases.filter({$0.name == type}).first
        }
    }
    
    public var name: String
    public var campaign: String
    public var feature: Feature
    public var payload: [String: Any] = [:]
    
    public init(name: String, feature: Feature, campaign: String, payload: [String: Any]) {
        self.name = name
        self.feature = feature
        self.campaign = campaign
        self.payload = payload
    }
}

@objc public enum ActionType: Int {
    case PIP
    case KEEP
    case CLOSE

    public var name: String {
        switch self {
        case .PIP:
            return "PIP"
        case .KEEP:
            return "KEEP"
        case .CLOSE:
            return "CLOSE"
        }
    }
}
