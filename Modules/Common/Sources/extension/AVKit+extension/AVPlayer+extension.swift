//
//  AVPlayer+extension.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/25/23.
//

import Foundation
import AVKit

public extension AVPlayer.TimeControlStatus {
    var name_SL: String {
        switch self {
        case .playing:
            return "playing"
        case .waitingToPlayAtSpecifiedRate:
            return "waitingToPlayAtSpecifiedRate"
        case .paused:
            return "paused"
        @unknown default:
            return ""
        }
    }
}
