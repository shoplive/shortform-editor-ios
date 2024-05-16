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


extension SLVideoEditorViewReactor : SLVideoCropViewControllerDelegate {
    func videoCropViewController(didFinish didCrop: Bool) {
        if didCrop {
            resultHandler?( .setCropBtnIsSelected(isSelected: true) )
        }
        else {
            resultHandler?( .setCropBtnIsSelected(isSelected: false) )
        }
    }
}
extension SLVideoEditorViewReactor : SLVideoVolumeViewControllerDelegate {
    func videoVolumeViewController(didFinish didChange: Bool) {
        if didChange {
            resultHandler?( .setVideoSoundBtnIsSelected(isSelected: true) )
        }
        else {
            resultHandler?( .setVideoSoundBtnIsSelected(isSelected: false) )
        }
        
    }
}
extension SLVideoEditorViewReactor : SLVideoSpeedRateViewControllerDelegate {
    func speedRateViewController(didFinish didChange: Bool) {
        if didChange {
            resultHandler?( .setVideoSpeedBtnIsSelected(isSelected: true) )
        }
        else {
            resultHandler?( .setVideoSpeedBtnIsSelected(isSelected: false) )
        }
    }
}
extension SLVideoEditorViewReactor : SLVideoFilterViewControllerDelegate {
    func filterViewController(didFinish didChange: Bool) {
        if didChange {
            resultHandler?( .setFilterBtnIsSelected(isSelected: true) )
        }
        else {
            resultHandler?( .setFilterBtnIsSelected(isSelected: false))
        }
    }
}
