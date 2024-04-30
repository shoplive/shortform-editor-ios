//
//  HostConfigModel.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 4/23/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit



struct HostConfigModel : BaseResponsable {
    public var _s: Int?
    public var _e: String?
    
    let campaign: Campaign?
    let shortform : Shortform?
    
    internal struct Campaign : Codable {
        let eventTraceHost, conversionTrackingHost : String?
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let parser = SLFlexibleParser(container: container)
            
            self.eventTraceHost = try parser.parse(targetType: String.self, key: CodingKeys.eventTraceHost)
            self.conversionTrackingHost = try parser.parse(targetType: String.self, key: CodingKeys.conversionTrackingHost)
        }
    }
    
    internal struct Shortform : Codable {
        let eventTraceHost, conversionTrackingHost : String?
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let parser = SLFlexibleParser(container: container)
            
            self.eventTraceHost = try parser.parse(targetType: String.self, key: CodingKeys.eventTraceHost)
            self.conversionTrackingHost = try parser.parse(targetType: String.self, key: CodingKeys.conversionTrackingHost)
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let parser = SLFlexibleParser(container: container)
        
        self._s = try parser.parse(targetType: Int.self, key: CodingKeys._s)
        self._e = try parser.parse(targetType: String.self, key: CodingKeys._e)
        self.campaign = try container.decodeIfPresent(HostConfigModel.Campaign.self, forKey: .campaign)
        self.shortform = try container.decodeIfPresent(HostConfigModel.Shortform.self, forKey: .shortform)
        
    }
}


