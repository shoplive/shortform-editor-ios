//
//  SLTimeTrimeSliderReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/13/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon


class SLTimeTrimeSliderReactor : NSObject, SLReactor {
    typealias globalConfig = ShopLiveEditorConfigurationManager
    
    enum Action {
        case setVideoDuration(Double)
        case setTimePerPixel(CGFloat)
        case initializeHandleView
        case setLeftHandleOffset(CGFloat)
        case setRighHandleOffset(CGFloat)
        case convertHandlePositionToTime(offset : CGFloat, handleType : SLVideoEditorSliderHandleType, contentOffset : CGFloat)
        case updateCropTime((start: CMTime, end: CMTime))
        case frameSliderDidScroll(UICollectionView)
        case setIsDraggin(Bool)
        case updateTimeIndicatorTime(Float)
        
    }
    
    enum Result {
        case cropTimeUpdated((start: CMTime, end: CMTime))
        case seekTo(CMTime)
        case initializeHandleView((startTime : CMTime, endTime : CMTime))
        case updateTimeIndicatorTime(Float)
    }
    
    
    var resultHandler: ((Result) -> ())?
    
    private var currentCropTime : (start: CMTime, end: CMTime) = (.zero, .zero)
    private var timePerPixel : CGFloat = 0
    private var leftHandleOffset : CGFloat = 0
    private var rightHandleOffset : CGFloat = 0
    private var videoDuration : Double = 0
    private var minTrimTime : CGFloat  {
        return globalConfig.shared.videoTrimOption.minVideoDuration
    }
    
    private var maxTrimTime : CGFloat {
        return globalConfig.shared.videoTrimOption.maxVideoDuration
    }
    private var isDragging : Bool = false
   
    func action(_ action: Action) {
        switch action {
        case .setVideoDuration(let duration):
            self.onSetVideoDuration(duration: duration)
        case .setTimePerPixel(let value):
            self.onSetTimePerPixel(value: value)
        case .initializeHandleView:
            self.onInitializeHandleView()
        case .setLeftHandleOffset(let offset):
            self.onSetLeftHandleOffset(offset: offset)
        case .setRighHandleOffset(let offset):
            self.onSetRightHandleOffset(offset: offset)
        case .convertHandlePositionToTime(let offset, let handleType, let contentOffset):
            self.onConvertHandlePositionToTime(offset: offset, handleType: handleType, contentOffset: contentOffset)
        case .updateCropTime((let startTime, let endTime)):
            self.onUpdateCropTime(startTime: startTime, endTime: endTime)
        case .frameSliderDidScroll(let cv):
            self.onFrameSliderDidScroll(cv: cv)
        case .setIsDraggin(let isDragging):
            self.onSetIsDraggin(isDragging: isDragging)
        case .updateTimeIndicatorTime(let time):
            self.onUpdateTimeIndicatorTime(time: time)
        }
    }
    
    private func onSetVideoDuration(duration : Double) {
        self.videoDuration = duration
    }
    
    private func onSetTimePerPixel(value : CGFloat) {
        self.timePerPixel = value
    }
    
    private func onInitializeHandleView() {
        let timeIndicatorEndTime = min(self.videoDuration, self.maxTrimTime )
        currentCropTime.start = .init(seconds: 0, preferredTimescale: 44100)
        currentCropTime.end = .init(seconds: Double(timeIndicatorEndTime), preferredTimescale: 44100)
        resultHandler?( .initializeHandleView((startTime: currentCropTime.start, endTime: currentCropTime.end)))
    }
    
    private func onSetLeftHandleOffset(offset : CGFloat) {
        self.leftHandleOffset = offset
    }
    
    private func onSetRightHandleOffset(offset : CGFloat) {
        self.rightHandleOffset = offset
    }
    
    private func onConvertHandlePositionToTime(offset : CGFloat, handleType : SLVideoEditorSliderHandleType, contentOffset : CGFloat) {
        let time = convertHandlePositionToTime(offset : offset, contentOffset : contentOffset)
        if handleType == .left {
            currentCropTime.start = time
        }
        else if handleType == .right {
            currentCropTime.end = time
        }
        resultHandler?( .seekTo(time) )
        if handleType != .timeIndicator {
            resultHandler?( .cropTimeUpdated(currentCropTime) )
        }
    }
    
    private func convertHandlePositionToTime(offset : CGFloat, contentOffset : CGFloat) -> CMTime {
        let realOffset = contentOffset + offset
        let time = CMTime(seconds: Double( realOffset * timePerPixel), preferredTimescale: 44100)
        return time
    }
    
    private func onUpdateCropTime(startTime : CMTime, endTime : CMTime) {
        self.currentCropTime.start = startTime
        self.currentCropTime.end = endTime
        
        resultHandler?( .cropTimeUpdated(currentCropTime) )
    }
    
    private func onFrameSliderDidScroll(cv : UICollectionView) {
        currentCropTime.start = convertHandlePositionToTime(offset : leftHandleOffset, contentOffset : cv.contentOffset.x)
        currentCropTime.end = convertHandlePositionToTime(offset : rightHandleOffset, contentOffset : cv.contentOffset.x)
        resultHandler?( .seekTo(currentCropTime.start) )
        resultHandler?( .cropTimeUpdated(currentCropTime) )
    }
    
    private func onSetIsDraggin(isDragging : Bool) {
        self.isDragging = isDragging
    }
    
    private func onUpdateTimeIndicatorTime(time : Float) {
        if isDragging == true { return }
        resultHandler?( .updateTimeIndicatorTime(time) )
    }
    
    
}
extension SLTimeTrimeSliderReactor {
    
}
