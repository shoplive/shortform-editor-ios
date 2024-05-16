//
//  SlVideoSpeedRateReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/10/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit


class SlVideoSpeedRateReactor : NSObject, SLReactor {
    
    enum Action {
        case viewDidLoad
        case viewDidLayoutSubView
        case viewDidAppear
        
        case setSpeed(CGFloat)
        
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
        
        case setInitialSpeed(CGFloat)
    }
    
    private var videoEditInfoDto : SLVideoEditInfoDTO
    private var isViewAppeared : Bool = false
    private var isPlaying : Bool = false
    private var initialSpeed : CGFloat = 1.0
    
    var resultHandler: ((Result) -> ())?
    
    init(videoEditInfoDto : SLVideoEditInfoDTO) {
        self.videoEditInfoDto = videoEditInfoDto
        super.init()
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .viewDidLoad:
            self.onViewDidLoad()
        case .viewDidLayoutSubView:
            self.onViewDidLayoutSubView()
        case .viewDidAppear:
            self.onViewDidAppear()
        case .setSpeed(let value):
            self.onSetSpeed(value: value)
        case .requestToggleVideoPlayOrPause:
            self.onRequestToggleVideoPlayOrPause()
        case .didPlayToEndTime:
            self.onDidPlayToEndTime()
        case .timeControlStatusUpdated(let timeControlStatus):
            self.onTimeControlStatusUpdated(status: timeControlStatus)
        case .requestOnConfirm:
            self.onRequestOnConfirm()
        }
        
    }
    
    private func onViewDidLoad() {
        resultHandler?( .setShortsVideo(videoEditInfoDto.shortsVideo) )
        resultHandler?( .setPlayerEndBoundaryTime(videoEditInfoDto.cropTime.end) )
        resultHandler?( .setFilterConfig(videoEditInfoDto.filterConfig?.filterConfig ?? "") )
        self.initialSpeed = videoEditInfoDto.videoSpeed
    }
    
    private func onViewDidLayoutSubView() {
        if isViewAppeared == false {
            resultHandler?( .setInitialSpeed(CGFloat(self.initialSpeed)))
        }
    }
    
    private func onViewDidAppear() {
        guard isViewAppeared == false else { return }
        isViewAppeared = true
        self.resultHandler?( .seekTo(self.videoEditInfoDto.cropTime.start) )
        self.resultHandler?( .playVideo )
        //여기서 크롭 적용 할 건지 말건지 고민중
    }
    
    private func onSetSpeed(value : CGFloat) {
        videoEditInfoDto.videoSpeed = value
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
    
    private func onTimeControlStatusUpdated(status : AVPlayer.TimeControlStatus) {
        if status == .playing {
            self.isPlaying = true
        }
        else {
            self.isPlaying = false
        }
    }
    
    private func onRequestOnConfirm() {
        if initialSpeed == videoEditInfoDto.videoSpeed {
            resultHandler?( .requestOnConfirm(false) )
        }
        else {
            resultHandler?( .requestOnConfirm(true) )
        }
    }
}

