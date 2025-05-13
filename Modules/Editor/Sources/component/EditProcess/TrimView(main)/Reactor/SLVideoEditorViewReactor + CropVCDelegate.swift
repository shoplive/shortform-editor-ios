//
//  SLVideoEditorViewReactor + CropVCDelegate.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/8/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon

extension SLVideoEditorMainViewReactor {
    private func applyVideoEditedFeatures() {
        let videoInfo = self.getVideoEditInfoDto()
        
        if let filter = videoInfo.filterConfig {
            onMainQueueResultHandler?( .setFilterConfigResult(filter.filterConfig) )
            onMainQueueResultHandler?( .setFilterIntensityResult(filter.filterIntensity) )
        }
        
        onMainQueueResultHandler?( .setSpeedRateResult(CGFloat(videoInfo.videoSpeed )) )
    }
}
