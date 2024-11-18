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
//        os_log("[DEBUG_LOG]%s", log)
        #endif
    }
    
    /**
        메모리 관련 비휘발성 로그볼때 사용
     */
    public static func memoryLog(_ log : String) {
        #if DEBUG
        os_log("[MEMORY_LOG] %s",log)
        #endif
    }
    
    /**
    개발 단계 일시적으로 로그 볼때 사용
     */
    public static func tempLog(_ log : String) {
        #if DEBUG
        os_log("[TEMP_LOG] %s",log)
        #endif
    }
    
    public static func publicLog(_ log : String) {
        guard Self.showLog else { return }
        let isMainThread = Thread.isMainThread ? "MAIN" : "OTHER"
        os_log("[SHOPLIVE - THREAD %s] %s",isMainThread,log)
    }
    
    public static var showLog : Bool = false
}
