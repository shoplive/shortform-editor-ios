//
//  SLVideoMainVolumeSubReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/24/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit

class SLVideoMainVolumeSubReactor : NSObject, SLReactor {
    
    enum Action {
        case initialize
        case setVolume(CGFloat)
        case videoEditInfoDto(SLVideoEditInfoDTO)
        case saveEditingStartValue
        case revertChange
    }
    
    enum Result {
        case setInitialValue(CGFloat)
        case setSliderValue(Int)
    }
    
    
    var resultHandler: ((Result) -> ())?
    
    
    private var videoEditInfoDTO : SLVideoEditInfoDTO?
    private var editingStartValue : Int = 100
    
    func action(_ action: Action) {
        switch action {
        case .initialize:
            self.onInitialize()
        case .videoEditInfoDto(let videoEditInfo):
            self.onSetVideoEditInfoDto(dto: videoEditInfo)
        case .setVolume(let value):
            self.onSetVolume(volume: value)
        case .saveEditingStartValue:
            self.onSaveEditingStartValue()
        case .revertChange:
            self.onRevertChange()
        }
    }
    
    private func onInitialize() {
        guard let dto = videoEditInfoDTO else { return }
        resultHandler?( .setInitialValue(CGFloat(dto.volume)) )
    }
    
    private func onSetVideoEditInfoDto(dto : SLVideoEditInfoDTO) {
        self.videoEditInfoDTO = dto
    }
    
    private func onSetVolume(volume : CGFloat) {
        guard let dto = videoEditInfoDTO else { return }
        dto.volume = Int(volume)
    }
    
    private func onSaveEditingStartValue() {
        self.editingStartValue = videoEditInfoDTO?.volume ?? 100
    }
    
    private func onRevertChange() {
        self.videoEditInfoDTO?.volume = self.editingStartValue
        self.resultHandler?( .setSliderValue(self.editingStartValue) )
    }
}
