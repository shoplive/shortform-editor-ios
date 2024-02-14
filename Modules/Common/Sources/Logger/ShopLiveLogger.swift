//
//  ShopLiveLogger.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/05/24.
//

import Foundation
import os.log

public class ShopLiveLogger {
    public static func debugLog(_ log: String) {
        #if DEBUG
        os_log("%s", log)
        #endif
    }
}
