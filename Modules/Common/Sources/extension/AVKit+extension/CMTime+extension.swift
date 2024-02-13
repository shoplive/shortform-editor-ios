//
//  CMTime+extension.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 5/3/23.
//

import Foundation
import AVKit

public extension CMTime {
    var timeSeconds_SL: Float64? {
        let cmSeconds = CMTimeGetSeconds(self)
        guard !cmSeconds.isInfinite && !cmSeconds.isNaN else {
            return nil
        }
        return cmSeconds
    }
    
    var isValid_SL: Bool {
        let cmSeconds = CMTimeGetSeconds(self)
        guard !cmSeconds.isInfinite && !cmSeconds.isNaN else {
            return false
        }
        
        return true
    }
    
    var roundedSeconds_SL: TimeInterval {
        return seconds.rounded()
    }
    
    var hours_SL:  Int { return Int(roundedSeconds_SL / 3600) }
    var minute_SL: Int { return Int(roundedSeconds_SL.truncatingRemainder(dividingBy: 3600) / 60) }
    var second_SL: Int { return Int(roundedSeconds_SL.truncatingRemainder(dividingBy: 60)) }
    var positionalTime_SL: String {
        return hours_SL > 0 ?
            String(format: "%d:%02d:%02d",
                   hours_SL, minute_SL, second_SL) :
            String(format: "00:%02d:%02d",
                   minute_SL, second_SL)
    }
}
