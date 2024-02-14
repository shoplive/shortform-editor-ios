//
//  ShopLiveDebouncer.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/05/24.
//

import Foundation

public class ShopLiveDebouncer {
    
    private let timeInterval: TimeInterval
    private var timer: Timer?
    
    public typealias Handler = () -> Void
    public var handler: Handler?
    
    public init(timeInterval: TimeInterval) {
        self.timeInterval = timeInterval
    }
    
    public func renewInterval() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { [weak self] (timer) in
            self?.timeIntervalDidFinish(for: timer)
        })
    }
    
    @objc private func timeIntervalDidFinish(for timer: Timer) {
        guard timer.isValid else {
            return
        }
        
        handler?()
        handler = nil
    }
    
}
