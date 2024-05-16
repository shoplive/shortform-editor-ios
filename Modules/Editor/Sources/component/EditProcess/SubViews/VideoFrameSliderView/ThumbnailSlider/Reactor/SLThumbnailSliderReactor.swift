//
//  SLThumbnailSliderReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/14/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon




class SLThumbnailSliderReactor : NSObject, SLReactor {
    
    
    enum Action {
        case convertHandlePositionToTime(offset : CGFloat, contentOffset : CGFloat)
        case setTimePerPixel(CGFloat)
        case frameSliderDidScroll(UICollectionView)
        
        case seekToHandleViewTo(targetTime : CMTime, cvWidth : CGFloat, cvContentSize : CGFloat)
    }
    
    enum Result {
        case seekTo(CMTime)
        
        case scrollFrameSliderTo(CGFloat)
        case moveHandleViewTo(CGFloat)
    }
    
    
    var resultHandler: ((Result) -> ())?
    
    private var timePerPixel : CGFloat = 0
    private var currentHandleOffset : CGFloat = 28 // 초기값 : SLVideoEditorThumbNailHandleViewd의 handleMargin
    private var defaultHandleMargin : CGFloat = 28
    
    
    
    func action(_ action: Action) {
        switch action {
        case .convertHandlePositionToTime(let offset, let contentOffset):
            self.onConvertHandlePositionToTime(offset: offset, contentOffset: contentOffset)
        case .setTimePerPixel(let value):
            self.onSetTimePerPixel(value: value)
        case .frameSliderDidScroll(let cv):
            self.onFrameSliderDidScroll(cv: cv)
        case .seekToHandleViewTo(let time, let cvWidth, let contentSize ):
            self.onSeekToHandleViewTo(time: time,cvWidth: cvWidth,cvContentSize: contentSize)
        }
    }
    
    private func onConvertHandlePositionToTime(offset : CGFloat, contentOffset : CGFloat) {
        self.currentHandleOffset = offset
        let time = convertHandlePositionToTime(offset : offset, contentOffset : contentOffset)
        resultHandler?( .seekTo(time) )
    }
    
    private func convertHandlePositionToTime(offset : CGFloat, contentOffset : CGFloat) -> CMTime {
        let realOffset = contentOffset + offset - defaultHandleMargin
        let time = CMTime(seconds: Double( realOffset * timePerPixel), preferredTimescale: 44100)
        return time
    }
    
    private func onSetTimePerPixel(value : CGFloat) {
        self.timePerPixel = value
    }
    
    private func onFrameSliderDidScroll(cv : UICollectionView) {
        resultHandler?( .seekTo(convertHandlePositionToTime(offset : currentHandleOffset, contentOffset : cv.contentOffset.x)) )
    }
    
    
    private func onSeekToHandleViewTo(time : CMTime, cvWidth : CGFloat,cvContentSize : CGFloat) {
        let targetContentOffset = (time.seconds / (timePerPixel)) + defaultHandleMargin
        
        if targetContentOffset > (cvWidth - 28) {
            let handleOffset = cvWidth - 28 - ( 60.0 * ( 9.0 / 16.0) ) //이건 일단 정확
            let maxScrollAvailable = cvContentSize - cvWidth
            var contentOffset = (CGFloat(time.seconds) / timePerPixel) + defaultHandleMargin - handleOffset
            contentOffset = min(maxScrollAvailable,contentOffset)
            
            self.currentHandleOffset = handleOffset
            
            resultHandler?( .scrollFrameSliderTo(contentOffset) )
            resultHandler?( .moveHandleViewTo(handleOffset) )
            
        }
        else {
            self.currentHandleOffset = targetContentOffset 
            resultHandler?( .moveHandleViewTo(targetContentOffset) )
        }
    }
}
extension SLVideoThumbnailReactor {
    
}
