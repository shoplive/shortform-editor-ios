//
//  ShopLiveLogger.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/03/02.
//

import Foundation
import os.log

class ShopLiveLogger {
    static func debugLog(_ log: String) {
        #if DEBUG
        os_log("%s", log)
        #endif
    }
}
