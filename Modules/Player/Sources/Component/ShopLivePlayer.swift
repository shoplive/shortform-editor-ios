//
//  ShopLivePlayer.swift
//  ShopLivePlayer
//
//  Created by ShopLive on 2021/07/30.
//

import AVKit
import ShopliveSDKCommon


final class ShopLivePlayer: AVPlayer {

    var superview: SLView?

    override init() {
        super.init()
    }

    init(superview: SLView) {
        super.init()
        self.superview = superview
    }
    
    
    
    deinit {
        
    }
}
