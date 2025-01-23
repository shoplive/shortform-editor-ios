//
//  ShopLiveKeySet.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

final class ShopLiveKeySet: NSObject, NSCoding {
    var alias: String
    var campaignKey: String
    var accessKey: String

    init(alias:String, campaignKey: String, accessKey: String) {
        self.alias = alias
        self.campaignKey = campaignKey
        self.accessKey = accessKey
        super.init()
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.alias, forKey: "alias")
        coder.encode(self.campaignKey, forKey: "campaignKey")
        coder.encode(self.accessKey, forKey: "accessKey")
    }

    required init?(coder: NSCoder) {
        self.alias = ""
        self.campaignKey = ""
        self.accessKey = ""
        if let alias = coder.decodeObject(forKey: "alias") as? String {
            self.alias = alias
        }

        if let campaignKey = coder.decodeObject(forKey: "campaignKey") as? String {
            self.campaignKey = campaignKey
        }

        if let accessKey = coder.decodeObject(forKey: "accessKey") as? String {
            self.accessKey = accessKey
        }

        super.init()
    }
    
    func hasEmptyValue() -> Bool {
        return self.alias.isEmpty || self.accessKey.isEmpty || self.campaignKey.isEmpty
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        return self.alias == (object as? ShopLiveKeySet)?.alias && self.accessKey == (object as? ShopLiveKeySet)?.accessKey && self.campaignKey == (object as? ShopLiveKeySet)?.campaignKey
    }
}
