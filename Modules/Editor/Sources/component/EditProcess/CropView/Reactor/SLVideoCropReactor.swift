//
//  SLVideoCropReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/8/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import ShopliveSDKCommon
import UIKit
import AVKit


class SLVideoCropReactor : NSObject, SLReactor {
    
    
    enum Action {
        case initialize
        case viewDidLoad
        case viewDidAppeared
        case viewDidLayOutSubView
        
        case setCropRect(CGRect)
        case setCropViewRect(CGRect)
        
        case requestToggleVideoPlayOrPause
        case didPlayToEndTime
        case timeControlStatusUpdated(AVPlayer.TimeControlStatus)
        case requestOnConfirm
    }
    
    enum Result {
        case setShortsVideo(ShortsVideo)
        case seekTo(CMTime)
        case setPlayerEndBoundaryTime(CMTime)
        
        case playVideo
        case pauseVideo
        
        case setFilterConfig(String)
        case requestOnConfirm(Bool)
        case setinitailCropRect(CGRect)
    }
    
    var resultHandler: ((Result) -> ())?
    
    private var videoEditInfoDto : SLVideoEditInfoDTO
    private var isViewAppeared : Bool = false
    private var isPlaying : Bool = false
    private var initialCropViewRect : CGRect = .zero
    
    
    init(videoInfo : SLVideoEditInfoDTO) {
        self.videoEditInfoDto = videoInfo
        super.init()
    }
    
    deinit {
        ShopLiveLogger.debugLog("SLVideoCropReactor deinited")
    }
    
    func action(_ action: Action) {
        switch action {
        case .initialize:
            self.onInitialize()
        case .viewDidLoad:
            self.onViewDidLoad()
        case .viewDidAppeared:
            self.onViewDidAppeared()
        case .viewDidLayOutSubView:
            self.onViewDidLayoutSubView()
        case .setCropRect(let cGRect):
            self.onSetCropRect(rect: cGRect)
        case .setCropViewRect(let rect):
            self.onSetCropViewRect(rect: rect)
        case .requestToggleVideoPlayOrPause:
            self.onRequestToggleVideoPlayOrPause()
        case .didPlayToEndTime:
            self.onDidPlayToEndTime()
        case .timeControlStatusUpdated(let timeControlStatus):
            self.onTimeControlStatusUpated(status: timeControlStatus)
        case .requestOnConfirm:
            self.onRequestOnConfirm()
        
        }
    }
    
    private func onInitialize() {
        resultHandler?( .setShortsVideo(videoEditInfoDto.shortsVideo) )
        resultHandler?( .setPlayerEndBoundaryTime(videoEditInfoDto.cropTime.end) )
        resultHandler?( .setFilterConfig(videoEditInfoDto.filterConfig?.filterConfig ?? "") )
        self.initialCropViewRect = videoEditInfoDto.cropViewRect
        
    }
    
    private func onViewDidLoad() {
        
    }
    
    private func onViewDidAppeared() {
        guard isViewAppeared == false else {
            return
        }
        isViewAppeared = true
        self.resultHandler?( .seekTo(self.videoEditInfoDto.cropTime.start) )
        self.resultHandler?( .playVideo )
        if videoEditInfoDto.cropViewRect != .zero {
            self.resultHandler?( .setinitailCropRect(videoEditInfoDto.cropViewRect) )
        }
    }
    
    private func onViewDidLayoutSubView() {
        
    }
    
    private func onSetCropRect(rect : CGRect) {
        videoEditInfoDto.realVideoCropRect = rect
    }
    
    private func onSetCropViewRect(rect : CGRect) {
        if isViewAppeared == false { return }
        videoEditInfoDto.cropViewRect = rect
    }
    
    private func onRequestToggleVideoPlayOrPause() {
        if isPlaying == false {
            resultHandler?( .playVideo )
        }
        else {
            resultHandler?( .pauseVideo )
        }
    }
    
    private func onDidPlayToEndTime() {
        resultHandler?( .seekTo(videoEditInfoDto.cropTime.start))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.resultHandler?( .playVideo )
        }
    }
    
    private func onTimeControlStatusUpated(status : AVPlayer.TimeControlStatus) {
        if status == .playing {
            self.isPlaying = true
        }
        else {
            self.isPlaying = false
        }
    }
    
    private func onRequestOnConfirm() {
        if videoEditInfoDto.cropViewRect == initialCropViewRect {
            resultHandler?( .requestOnConfirm(false) )
        }
        else {
            resultHandler?( .requestOnConfirm(true))
        }
    }
}
extension SLVideoCropReactor {
    
}
