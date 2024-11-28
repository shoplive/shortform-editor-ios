//
//  SLVideoMainSpeedSubReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/23/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit



class SLVideoMainSpeedSubReactor : NSObject, SLReactor {
    
    enum Action {
        case initialize
        case setSpeed(CGFloat)
        case videoEditInfoDto(SLVideoEditInfoDTO)
        case saveEditingStartSpeedValue
        case revertChanges
        case checkVideoDuration
        case setToOrigin
    }
    
    enum Result {
        case setInitialValue(CGFloat)
        case setVideoDuration(String)
        case onValueChanged
        case setSliderValue(CGFloat)
        case showToast(String)
//        case onConfirm
        case confirmWithOrigin
        case confirmWithChange
    }
    
    var resultHandler: ((Result) -> ())?
    
    
    private var videoEditInfoDTO : SLVideoEditInfoDTO?
    private var editingStartSpeedValue : Double = 0
    private var currentVideoDurationString : String = ""
    private var currentVideoDurationCGFloat : CGFloat = 0
    private let defaultVideoSpeed : Double = 1.0
    
    func action(_ action: Action) {
        switch action {
        case .initialize:
            self.onInitialize()
        case .videoEditInfoDto(let videoEditInfo):
            self.onSetVideoEditInfoDto(dto: videoEditInfo)
        case .setSpeed(let speed):
            self.onSetSpeed(speed: speed)
        case .saveEditingStartSpeedValue:
            self.onSaveEditingStartSpeedValue()
        case .revertChanges:
            self.onRevertChanges()
        case .checkVideoDuration:
            self.onCheckVideoDuration()
        case .setToOrigin:
            self.onSetToOrigin()
        }
    }
    
    private func onInitialize() {
        guard let dto = videoEditInfoDTO else { return }
        resultHandler?( .setInitialValue(CGFloat(dto.videoSpeed)) )
    }
    
    private func onSetVideoEditInfoDto(dto : SLVideoEditInfoDTO) {
        self.videoEditInfoDTO = dto
        self.calculateVideoDuation()
    }
    
    private func onSetSpeed(speed : CGFloat) {
        self.videoEditInfoDTO?.videoSpeed = Double(speed)
        self.calculateVideoDuation()
    }
    
    private func calculateVideoDuation() {
        guard let dto = self.videoEditInfoDTO else { return }
        let originVideoDuration = dto.cropTime.end.seconds - dto.cropTime.start.seconds
        let modifiedVideoDuration = originVideoDuration / dto.videoSpeed
        self.currentVideoDurationCGFloat = modifiedVideoDuration
        let result = ShopLiveShortformEditorSDKStrings.Editor.Trim.Cut.Sec.shoplive(Int(modifiedVideoDuration))
        
        
        
        if result != currentVideoDurationString {
            currentVideoDurationString = result
            resultHandler?( .onValueChanged )
        }
        resultHandler?( .setVideoDuration(result) )
    }
    
    private func onSaveEditingStartSpeedValue() {
        guard let dto = self.videoEditInfoDTO else { return }
        self.editingStartSpeedValue = dto.videoSpeed
    }
    
    private func onRevertChanges() {
        self.videoEditInfoDTO?.videoSpeed = editingStartSpeedValue
        guard let dto = self.videoEditInfoDTO else { return }
        let originVideoDuration = dto.cropTime.end.seconds - dto.cropTime.start.seconds
        let modifiedVideoDuration = originVideoDuration / dto.videoSpeed
        self.currentVideoDurationCGFloat = modifiedVideoDuration
        let result = ShopLiveShortformEditorSDKStrings.Editor.Trim.Cut.Sec.shoplive(Int(modifiedVideoDuration))
        
        if result != currentVideoDurationString {
            currentVideoDurationString = result
            resultHandler?( .onValueChanged )
        }
        resultHandler?( .setVideoDuration(result) )
        resultHandler?( .setSliderValue(CGFloat(dto.videoSpeed)))
    }
    
    private func onCheckVideoDuration() {
        let minDuration = ShopLiveEditorConfigurationManager.shared.videoTrimOption.minVideoDuration
        let maxDuration = ShopLiveEditorConfigurationManager.shared.videoTrimOption.maxVideoDuration
        
        if currentVideoDurationCGFloat < minDuration {
            let message = ShopLiveShortformEditorSDKStrings.Editor.Alert.Min.Duration.shoplive(Int(minDuration))
            resultHandler?( .showToast(message) )
        }
        else if currentVideoDurationCGFloat > maxDuration {
            let message = ShopLiveShortformEditorSDKStrings.Editor.Alert.Max.Duration.shoplive(Int(maxDuration))
            resultHandler?( .showToast(message) )
        }
        else {
            guard let dto = self.videoEditInfoDTO else { return }
            if dto.videoSpeed == defaultVideoSpeed {
                resultHandler?( .confirmWithOrigin )
            }
            else {
                resultHandler?( .confirmWithChange )
            }
        }
    }
    
    private func onSetToOrigin() {
        self.editingStartSpeedValue = 1.0
        self.videoEditInfoDTO?.videoSpeed = Double(1.0)
        guard let dto = self.videoEditInfoDTO else { return }
        let originVideoDuration = dto.cropTime.end.seconds - dto.cropTime.start.seconds
        let modifiedVideoDuration = originVideoDuration / dto.videoSpeed
        self.currentVideoDurationCGFloat = modifiedVideoDuration
        self.currentVideoDurationCGFloat = modifiedVideoDuration
        let result = ShopLiveShortformEditorSDKStrings.Editor.Trim.Cut.Sec.shoplive(Int(modifiedVideoDuration))
        if result != currentVideoDurationString {
            currentVideoDurationString = result
            resultHandler?( .onValueChanged )
        }
        resultHandler?( .setVideoDuration(result) )
        resultHandler?( .setSliderValue(CGFloat(dto.videoSpeed)))
    }
    
}
extension SLVideoMainSpeedSubReactor {
}
