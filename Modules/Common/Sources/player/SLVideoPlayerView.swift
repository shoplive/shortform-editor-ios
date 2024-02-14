//
//  SLVideoPlayerView.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation
import UIKit
import AVKit
import AVFoundation

class SLVideoPlayerView: UIView {

    override static var layerClass: AnyClass { AVPlayerLayer.self }
    
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    private var playerLayer: AVPlayerLayer { layer as! AVPlayerLayer }
}
