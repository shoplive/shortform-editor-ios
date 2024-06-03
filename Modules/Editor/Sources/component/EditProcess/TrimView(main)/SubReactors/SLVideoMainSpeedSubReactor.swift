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
        
        
    }
    
    enum Result {
        case setInitialValue(CGFloat)
        case setVideoDuration(String)
        case onValueChanged
        
    }
    
    var resultHandler: ((Result) -> ())?
    
    
    private var videoEditInfoDTO : SLVideoEditInfoDTO?
    private var latestSpeedValue : String = ""
    
    func action(_ action: Action) {
        switch action {
        case .initialize:
            self.onInitialize()
        case .videoEditInfoDto(let videoEditInfo):
            self.onSetVideoEditInfoDto(dto: videoEditInfo)
        case .setSpeed(let speed):
            self.onSetSpeed(speed: speed)
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
        let result = ShopLiveShortformEditorSDKStrings.Video.Frame.Slider.Seconds.label(Int(modifiedVideoDuration))
        
        if result != latestSpeedValue {
            latestSpeedValue = result
            resultHandler?( .onValueChanged )
        }
        resultHandler?( .setVideoDuration(result) )
    }
    
}
extension SLVideoMainSpeedSubReactor {
    
}
