//
//  MPVolumeView+extension.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation
import UIKit
import MediaPlayer

public extension MPVolumeView {
    static func setVolume_SL(_ volume: Float) {
        let volumeView = MPVolumeView()
        let slider = volumeView.subviews.first(where: { $0 is UISlider }) as? UISlider
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
            slider?.value = volume
        }
    }
}
