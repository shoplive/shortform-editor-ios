//
//  ShopLivePlayerItem.swift
//  ShopLivePlayer
//
//  Created by ShopLive on 2021/08/01.
//

import Foundation
import AVKit

///플레이어 자체의 값을 가지고 있는 아이템
final class ShopLivePlayerItem: NSObject {
    @objc dynamic var player: AVPlayer?
    @objc dynamic var playerLayer: AVPlayerLayer?
}
