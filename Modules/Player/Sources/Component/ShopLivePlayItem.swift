//
//  ShopLivePlayItem.swift
//  ShopLivePlayer
//
//  Created by ShopLive on 2021/08/01.
//

import Foundation
import AVKit

final class ShopLivePlayItem: NSObject {
    @objc dynamic var videoUrl: URL? = nil
    @objc dynamic var urlAsset: AVURLAsset? = nil
    @objc dynamic var playerItem: AVPlayerItem? = nil
    @objc dynamic var perfMeasurements: PerfMeasurements? = nil
    @objc dynamic var videoOutput: AVPlayerItemVideoOutput? = nil
}
