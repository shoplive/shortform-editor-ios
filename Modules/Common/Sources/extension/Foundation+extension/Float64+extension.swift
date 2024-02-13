//
//  Float64+extension.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 5/3/23.
//

import Foundation

public extension Float64 {
    
    var seconds_SL: Double {
        return ceil(self * 1000000.0)
    }
    
    var isValid_SL: Bool {
        guard !self.isNaN && !self.isInfinite else { return false }
        return true
    }
    
    var timeHourMinuteSeconds_SL: String {
        guard isValid_SL else { return "00:00:00" }
        let hours = String(format: "%02d", Int((self/3600).truncatingRemainder(dividingBy: 3600)))//(intTime / 3600))
        let minutes = String(format: "%02d", Int((self/60).truncatingRemainder(dividingBy: 60)))
        let seconds = String(format: "%02d", Int(truncatingRemainder(dividingBy: 60)))
        
        let intMilliseconds = Int((self*100).truncatingRemainder(dividingBy: 100))
        let milliseconds = String(format: "%02d", intMilliseconds < 0 ? 0 : intMilliseconds)
        
        return "\(hours):\(minutes):\(seconds).\(milliseconds)"
    }
}
