//
//  SLVideoVolumeReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/10/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit


class SLVideoVolumeReactor : NSObject, SLReactor {
    
    enum Action {
        case viewDidLoad
        case viewDidLayoutSubView
        case viewDidAppear
        
        case setVolume(CGFloat)
        
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
        
        case setInitialVolume(CGFloat)
    }
    
    
    private var videoEditInfoDto : SLVideoEditInfoDTO
    private var isViewAppeared : Bool = false
    private var isPlaying : Bool = false
    private var initialVolume : Int = 100
    
    
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
        case .setVolume(let value):
            self.onSetVolume(value: value)
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
        self.initialVolume = videoEditInfoDto.volume
    }
    
    private func onViewDidLayoutSubView() {
        if isViewAppeared == false {
            resultHandler?( .setInitialVolume(CGFloat(self.initialVolume)))
        }
    }
    
    private func onViewDidAppear() {
        guard isViewAppeared == false else { return }
        isViewAppeared = true
        self.resultHandler?( .seekTo(self.videoEditInfoDto.cropTime.start) )
        self.resultHandler?( .playVideo )
        //여기서 크롭 적용 할 건지 말건지 고민중
    }
    
    private func onSetVolume(value : CGFloat) {
        videoEditInfoDto.volume = Int(floor(value))
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
        if initialVolume == videoEditInfoDto.volume {
            resultHandler?( .requestOnConfirm(false) )
        }
        else {
            resultHandler?( .requestOnConfirm(true) )
        }
    }
    
}
extension SLVideoVolumeReactor {
    
}
