//
//  SLVideoEditorViewReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/7/23.
//

import Foundation
import ShopliveSDKCommon
import UIKit
import AVKit


class SLVideoEditorMainViewReactor : NSObject,  SLReactor {
    typealias globalConfig = ShopLiveEditorConfigurationManager
    
    enum VideoConfigApplyType {
        case all
        case speed
        case volume
        case filter
    }
    
    
    enum Action {
        case viewDidLoad
        case viewDidLayOutSubView
        case setCropStartTime(CMTime)
        case setCropEndTime(CMTime)
        
        case setCropRect(CGRect)
        
        
        case resetDataOnViewRotation
        case setShortformEditorDelegate(ShopLiveShortformEditorDelegate?)
        case setVideoEditorDelegate(ShopLiveVideoEditorDelegate?)
        
        case requestToggleVideoPlayOrPause
        case didPlayToEndTime
        case timeControlStatusUpdated(AVPlayer.TimeControlStatus)
        case videoTimeUpdated(Double)
        case setFilterConfig(SLFilterConfig?)
        case checkIfNextStepIsAvailable
        
        case applyVideoConfiChange(VideoConfigApplyType)
    }
    
    enum Result {
        case setShortsVideo(ShortsVideo)
        case seekTo(CMTime)
        
        
        case setPlayBtnVisible(Bool)
        case presentViewController(UIViewController)
        
        case setTimeIndicatorLineTime(Float)
        case resetTimeIndicatorLine
        
        case setPlayerEndBoundaryTime(CMTime)
        
        
        case playVideo
        case pauseVideo
        
        case setFilterConfigResult(String)
        case setFilterIntensityResult(Float)
        case setSpeedRateResult(CGFloat)
        case setCropResult(CGRect)
        
        
        
        
        case setCropBtnIsSelected(isSelected: Bool)
        case setCropViewIsHidden(Bool)//쓸지 안쓸지 결정중
        case setVideoSoundBtnIsSelected(isSelected : Bool)
        case setVideoSpeedBtnIsSelected(isSelected : Bool)
        case setFilterBtnVisible(Bool)
        case setFilterBtnIsSelected(isSelected : Bool)
        
        case showThumbnailViewController
    }
    
    
    private var videoEditInfoDto : SLVideoEditInfoDTO
    private var isPlaying : Bool = false
    private var isCropTimeUpdated : Bool = false
    private var isViewAppeared : Bool = false
    
    private weak var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    private weak var videoEditorDelegate : ShopLiveVideoEditorDelegate?
    
    private var imageGenerator : AVAssetImageGenerator
    private var imageGeneratorQueue = DispatchQueue(label: "shopLiveImageGeneratorQueue",qos: .background)
    
    
    
    var resultHandler: ((Result) -> ())?
    var onMainQueueResultHandler : ((Result) -> ())?
    
    
    
    init(shortsVideo : ShortsVideo){
        videoEditInfoDto = SLVideoEditInfoDTO(shortsVideo: shortsVideo)
        let asset = AVAsset(url: shortsVideo.videoUrl)
        self.imageGenerator = AVAssetImageGenerator(asset: asset )
        self.imageGenerator.appliesPreferredTrackTransform = true
        self.imageGenerator.maximumSize = CGSize(width: 720, height: 1280)
        self.imageGenerator.apertureMode = .cleanAperture
        super.init()
    }
    
    deinit {
        ShopLiveLogger.memoryLog("SLVideoEditorViewReactor deinited")
    }
    
    func action(_ action: Action) {
        switch action {
        case .setShortformEditorDelegate(let delegate):
            self.shortformEditorDelegate = delegate
        case .setVideoEditorDelegate(let delegate):
            self.videoEditorDelegate = delegate
        case .resetDataOnViewRotation:
            self.resetDataOnViewRotation()
        case .viewDidLoad:
            self.onViewDidLoad()
        case .viewDidLayOutSubView:
            self.onViewDidLayoutSubView()
        case .setCropStartTime(let time):
            self.onSetCropStartTime(startTime: time)
        case .setCropEndTime(let time):
            self.onSetCropEndTime(endTime: time)
        case .setCropRect(let rect):
            videoEditInfoDto.realVideoCropRect = rect
        case .requestToggleVideoPlayOrPause:
            self.didTapPlayerView()
        case .didPlayToEndTime:
            self.onDidPlayToEndTime()
        case .timeControlStatusUpdated(let timeControlStatus):
            self.onTimeControlStatusUpdated(timeControlStatus: timeControlStatus)
        case .videoTimeUpdated(let time):
            self.onVideoTimeUpdated(time: time)
        case .setFilterConfig(let filterConfig):
            self.onSetFilterConfig(filterConfig: filterConfig)
        case .checkIfNextStepIsAvailable:
            self.onCheckIfNextStepIsAvailable()
        case .applyVideoConfiChange(let type):
            self.onApplyVideoConfigChanges(type : type)
        }
        
    }
    
    private func resetDataOnViewRotation() {
        videoEditInfoDto.cropTime = (.zero, .zero)
        videoEditInfoDto.realVideoCropRect = .zero
        onViewDidLoad()
        
    }
    
    
    private func onViewDidLoad(){
        
        //TODO: ShopLiveShortformEditorFilterListManager.shared.isFilterExist
        onMainQueueResultHandler?( .setFilterBtnVisible(true) )
        if let duration = videoEditInfoDto.shortsVideo.player?.currentItem?.duration {
            
            resultHandler?( .setShortsVideo(videoEditInfoDto.shortsVideo) )
            
            
            if let size = videoEditInfoDto.shortsVideo.getVideoSize() {
                videoEditInfoDto.realVideoCropRect = .init(origin: .zero, size: size)
            }
            
            let seconds = CMTimeGetSeconds(duration)
            var initialEndTime : CGFloat = 0
            let maxVideoTrimTime = globalConfig.shared.videoTrimOption.maxVideoDuration
            initialEndTime = seconds >= maxVideoTrimTime ? maxVideoTrimTime : seconds
            
            if seconds.isNaN == false {
                videoEditInfoDto.cropTime.start = CMTime(seconds: 0, preferredTimescale: 44100)
                videoEditInfoDto.cropTime.end = CMTime(seconds: initialEndTime , preferredTimescale: 44100)
            }
            else {
                let seconds = videoEditInfoDto.shortsVideo.getVideoDuration()
                initialEndTime = seconds >= maxVideoTrimTime ? maxVideoTrimTime : seconds
                videoEditInfoDto.cropTime.start = CMTime(seconds: 0, preferredTimescale: 44100)
                videoEditInfoDto.cropTime.end = CMTime(seconds: initialEndTime , preferredTimescale: 44100)
            }
            
            resultHandler?( .setPlayerEndBoundaryTime(videoEditInfoDto.cropTime.end) )
        }
        else {
            ShopLiveLogger.debugLog("[HASSAN LOG] settingCropTimeFailed")
        }
    }
    
    private func onViewDidLayoutSubView() {
        if isViewAppeared == false {
            isViewAppeared = true
        }
    }
    
    private func onSetCropStartTime(startTime : CMTime) {
        videoEditInfoDto.cropTime.start = startTime
        self.isCropTimeUpdated = true
    }
    
    private func onSetCropEndTime(endTime : CMTime) {
        videoEditInfoDto.cropTime.end = endTime
        self.isCropTimeUpdated = true
        resultHandler?( .setPlayerEndBoundaryTime(endTime) )
    }
    
//    private func onRequestViewPop() {
//        let bundle = Bundle(for: type(of: self))
//        let cancelAlert = UIAlertController(title: "editor.encoding.cancel.alert.title".localizedString(bundle: bundle), message: nil, preferredStyle: .alert)
//        cancelAlert.addAction(.init(title: "alert.no".localizedString(bundle: bundle), style: .cancel))
//        cancelAlert.addAction(.init(title: "alert.yes".localizedString(bundle: bundle), style: .default, handler: { [weak self] action in
//            self?.videoConverter.cancelConvert()
//            self?.onMainQueueResultHandler?(.popViewWithMessage)
//        }))
//        onMainQueueResultHandler?( .showAlert(cancelAlert) )
//    }
    
    private func didTapPlayerView() {
        if isCropTimeUpdated {
            onMainQueueResultHandler?( .seekTo(videoEditInfoDto.cropTime.start) )
            isCropTimeUpdated = false
        }
        
        if isPlaying {
            onMainQueueResultHandler?( .pauseVideo )
        }
        else {
            onMainQueueResultHandler?( .playVideo )
        }
    }
    
    private func onDidPlayToEndTime() {
        onMainQueueResultHandler?( .seekTo(videoEditInfoDto.cropTime.start))
        onMainQueueResultHandler?( .resetTimeIndicatorLine )
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.onMainQueueResultHandler?( .playVideo )
        }
        
    }
    
    private func onTimeControlStatusUpdated(timeControlStatus : AVPlayer.TimeControlStatus) {
        switch timeControlStatus {
        case .paused:
            isPlaying = false
        case .playing:
            isPlaying = true
        default:
            break
        }
        onMainQueueResultHandler?( .setPlayBtnVisible(isPlaying ? false : true))
    }
    
    private func onVideoTimeUpdated(time : Double) {
        onMainQueueResultHandler?( .setTimeIndicatorLineTime(Float(time)) )
        
    }
    
    private func onSetFilterConfig(filterConfig : SLFilterConfig?){
        videoEditInfoDto.filterConfig = filterConfig
    }
    
    private func onCheckIfNextStepIsAvailable() {
        onMainQueueResultHandler?( .showThumbnailViewController )
    }
    
    private func onApplyVideoConfigChanges(type : VideoConfigApplyType) {
        let videoInfo = self.getVideoEditInfoDto()
        
        if type == .filter || type == .all {
            if let filter = videoInfo.filterConfig {
                onMainQueueResultHandler?( .setFilterConfigResult(filter.filterConfig) )
                onMainQueueResultHandler?( .setFilterIntensityResult(filter.filterIntensity) )
            }
        }
        
        if type == .speed || type == .all {
            onMainQueueResultHandler?( .setSpeedRateResult(CGFloat(videoInfo.videoSpeed )) )
        }
    }
}
//MARK: - GETTER
extension SLVideoEditorMainViewReactor {
    func getVideoUrl() -> URL {
        return videoEditInfoDto.shortsVideo.videoUrl
    }
    
    func getVideoSize() -> CGSize? {
        return videoEditInfoDto.shortsVideo.getVideoSize()
    }
    
    func getVideoEditInfoDto() -> SLVideoEditInfoDTO {
        return videoEditInfoDto
    }
}
