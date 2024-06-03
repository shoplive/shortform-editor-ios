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


extension SLVideoEditorMainViewReactor : SLVideoCropViewControllerDelegate {
    func videoCropViewController(didFinish didCrop: Bool?) {
        onMainQueueResultHandler?( .playVideo )
        guard let didCrop = didCrop else { return }
        if didCrop {
            onMainQueueResultHandler?( .setCropBtnIsSelected(isSelected: true) )
        }
        else {
            onMainQueueResultHandler?( .setCropBtnIsSelected(isSelected: false) )
        }
        onMainQueueResultHandler?( .playVideo )
        applyVideoEditedFeatures()
    }
}
extension SLVideoEditorMainViewReactor : SLVideoVolumeViewControllerDelegate {
    func videoVolumeViewController(didFinish didChange: Bool?) {
        onMainQueueResultHandler?( .playVideo )
        guard let didChange = didChange else { return }
        if didChange {
            onMainQueueResultHandler?( .setVideoSoundBtnIsSelected(isSelected: true) )
        }
        else {
            onMainQueueResultHandler?( .setVideoSoundBtnIsSelected(isSelected: false) )
        }
        applyVideoEditedFeatures()
    }
}
extension SLVideoEditorMainViewReactor : SLVideoSpeedRateViewControllerDelegate {
    func speedRateViewController(didFinish didChange: Bool?) {
        onMainQueueResultHandler?( .playVideo )
        guard let didChange = didChange else { return }
        if didChange {
            onMainQueueResultHandler?( .setVideoSpeedBtnIsSelected(isSelected: true) )
        }
        else {
            onMainQueueResultHandler?( .setVideoSpeedBtnIsSelected(isSelected: false) )
        }
        applyVideoEditedFeatures()
    }
}
extension SLVideoEditorMainViewReactor : SLVideoFilterViewControllerDelegate {
    func filterViewController(didFinish didChange: Bool?) {
        onMainQueueResultHandler?( .playVideo )
        guard let didChange = didChange else { return }
        if didChange {
            onMainQueueResultHandler?( .setFilterBtnIsSelected(isSelected: true) )
        }
        else {
            onMainQueueResultHandler?( .setFilterBtnIsSelected(isSelected: false))
        }
        applyVideoEditedFeatures()
    }
}

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
