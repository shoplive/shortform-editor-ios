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


class SLVideoEditorViewReactor : NSObject,  SLReactor {
    typealias globalConfig = ShopLiveEditorConfigurationManager
    
    enum Action {
        case viewDidLoad
        case viewDidLayOutSubView
        case setCropStartTime(CMTime)
        case setCropEndTime(CMTime)
        case setCropRect(CGRect)
        case requestVideoConvert
        case requestViewPop
        case resetDataOnViewRotation
        case setShortformEditorDelegate(ShopLiveShortformEditorDelegate?)
        case setVideoEditorDelegate(ShopLiveVideoEditorDelegate?)
    }
    
    enum Result {
        case initCropView
        case updateConvertPercentage(Int)
        case setShortsVideo(ShortsVideo)
        case seekTo(CMTime)
        
        
        case setPlayBtnVisible(Bool)
        case setLoadingVisible(Bool)
        case resetLoadingProgress
        case setNextButtnEnable(Bool)
        case showUploadInfoViewController(UIViewController)
        case setPlayerViewPlayState(Bool)
        case setTimeIndicatorLineVisible(Bool)
        case setTimeIndicatorLineTime(Float)
        case resetTimeIndicatorLine
        
        case setPlayerEndBoundaryTime(CMTime)
        case popView
        case popViewWithMessage
        case showAlert(UIAlertController)
        
    }
    
    
    private var temporaryUploadInfo: SLUploadAttachmentInfo?
    private var videoConverter : SLVideoConverter = SLVideoConverter()
    private var cropTime : (start : CMTime, end : CMTime) = (.zero, .zero)
    private var cropRect : CGRect = .zero
    private var shortsVideo : ShortsVideo
    private var minTrimTime : CGFloat  {
        return globalConfig.shared.videoTrimOption.minVideoDuration
    }
    private var maxTrimTime : CGFloat {
        return globalConfig.shared.videoTrimOption.maxVideoDuration
    }
    private var isPlaying : Bool = false
    private var isCropTimeUpdated : Bool = false
    private var isViewAppeared : Bool = false
    private weak var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    private weak var videoEditorDelegate : ShopLiveVideoEditorDelegate?
    
    
    var resultHandler: ((Result) -> ())?
    var onMainQueueResultHandler : ((Result) -> ())?
    
    
    init(shortsVideo : ShortsVideo){
        self.shortsVideo = shortsVideo
        self.shortsVideo.seekNotificationEnabled = false
        super.init()
        videoConverter.delegate = self
    }
    
    deinit {
        ShopLiveLogger.debugLog("[ShopliveShortformEditor] SLVideoEditorViewReactor deinited")
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
            self.cropTime.start = time
        case .setCropEndTime(let time):
            self.cropTime.end = time
        case .setCropRect(let rect):
            self.cropRect = rect
            
        case .requestVideoConvert:
            self.processVideoConvert()
        case .requestViewPop:
            self.onRequestViewPop()
        }
        
    }
    
    private func resetDataOnViewRotation() {
        cropTime = (.zero, .zero)
        cropRect = .zero
        onViewDidLoad()
        
    }
    
    
    private func onViewDidLoad(){
        if let duration = shortsVideo.player?.currentItem?.duration {
            resultHandler?( .setShortsVideo(shortsVideo) )
            
            let seconds = CMTimeGetSeconds(duration)
            var initialEndTime : CGFloat = 0
            let maxVideoTrimTime = globalConfig.shared.videoTrimOption.maxVideoDuration
            initialEndTime = seconds >= maxVideoTrimTime ? maxVideoTrimTime : seconds
            
            cropTime.end = CMTime(seconds: initialEndTime , preferredTimescale: 44100)
        }
    }
    
    private func onViewDidLayoutSubView() {
        if isViewAppeared == false {
            onMainQueueResultHandler?( .initCropView )
            isViewAppeared = true
        }
    }
    
    private func processVideoConvert() {
        guard let videoSize = shortsVideo.getVideoSize(),
              let startTime = cropTime.start.timeSeconds_SL,
              let endTime = cropTime.end.timeSeconds_SL,
              startTime < endTime else { return }
        let videoUrl = shortsVideo.videoUrl.absoluteString
        

        onMainQueueResultHandler?( .setTimeIndicatorLineVisible(false) )
        onMainQueueResultHandler?( .seekTo(cropTime.start) )
        onMainQueueResultHandler?( .resetTimeIndicatorLine )
        
        onMainQueueResultHandler?( .setPlayBtnVisible(false) )
        
        onMainQueueResultHandler?( .setLoadingVisible(true) )
        onMainQueueResultHandler?( .setNextButtnEnable(false) )
        
        let videoInfo = SLVideoInfo(videoPath: videoUrl,
                                    cropRect: cropRect,
                                    videoSize: videoSize,
                                    timeRange: (startTime, endTime),
                                    fileName: (videoUrl as NSString).lastPathComponent)
        
        videoConverter.convertVideo(videoInfo: videoInfo) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .Success(videoPath: let videoPath):
                
                self.onMainQueueResultHandler?( .setNextButtnEnable(true) )
                self.onMainQueueResultHandler?( .setLoadingVisible(false) )
                self.onMainQueueResultHandler?( .setPlayBtnVisible(true) )
                if let videoEditorDelegate = self.videoEditorDelegate {
                    self.finishEntireProcess(videoPath: videoPath)
                }
                else {
                    self.showUPloadInfoController(videoPath: videoPath)
                }
                
            case .Failed(let e):
                guard let error = e as? SLVideoConvertError else { return }
                self.onMainQueueResultHandler?( .setLoadingVisible(false) )
                self.onMainQueueResultHandler?( .resetLoadingProgress )
                break
            }
        }
    }
    
    private func finishEntireProcess(videoPath : String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.videoEditorDelegate?.onShopLiveVideoEditorSuccess?(videoPath: videoPath)
        }
        
    }
    
    private func showUPloadInfoController(videoPath : String) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            var vc : SLUploadInfoController2
            if let uploadInfo = self.temporaryUploadInfo {
                self.temporaryUploadInfo?.videoUrl = videoPath
                vc = SLUploadInfoController2(uploadInfo: uploadInfo)
            }
            else {
                vc = SLUploadInfoController2(videoUrl: videoPath )
            }
            vc.delegate = self
            vc.shortformEditorDelegate = self.shortformEditorDelegate
            vc.videoEditorDelegate = self.videoEditorDelegate
            self.onMainQueueResultHandler?( .showUploadInfoViewController(vc) )
        }
    }
    
    private func onRequestViewPop() {
        if videoConverter.inConvert {
            let bundle = Bundle(for: type(of: self))
            let cancelAlert = UIAlertController(title: "editor.encoding.cancel.alert.title".localizedString(bundle: bundle), message: nil, preferredStyle: .alert)
            cancelAlert.addAction(.init(title: "alert.no".localizedString(bundle: bundle), style: .cancel))
            cancelAlert.addAction(.init(title: "alert.yes".localizedString(bundle: bundle), style: .default, handler: { [weak self] action in
                self?.videoConverter.cancelConvert()
                self?.onMainQueueResultHandler?(.popViewWithMessage)
            }))
            onMainQueueResultHandler?( .showAlert(cancelAlert) )
        }
        else {
            self.pause()
            self.onMainQueueResultHandler?(.popView)
        }
    }
    
    func getVideoUrl() -> URL {
        return shortsVideo.videoUrl
    }
    
    func getVideoSize() -> CGSize? {
        return shortsVideo.getVideoSize()
    }
    
    func play(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.shortsVideo.player?.play()
        }
    }
    
    func pause(){
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.shortsVideo.player?.pause()
        }
    }
}
extension SLVideoEditorViewReactor : SLUploadInfoControllerDelegate {
    func temporaryUploadInfo(uploadInfo: SLUploadAttachmentInfo) {
        self.temporaryUploadInfo = uploadInfo
        onMainQueueResultHandler?( .resetLoadingProgress )
    }
}
extension SLVideoEditorViewReactor  : SLVideoConverterDelegate {
    func updateConvertPercent(percent: Int) {
        onMainQueueResultHandler?( .updateConvertPercentage(percent))
    }
}
extension SLVideoEditorViewReactor : SLShortsVideoPlayerDelegate {
    func onVideoTimeUpdated(time: Float64) {
        onMainQueueResultHandler?( .setTimeIndicatorLineTime(Float(time)))
    }
    
    func handlePlayerItemStatus(_ status: AVPlayerItem.Status) {
        //no - op
    }
    
    func handleTimeControlStatus(_ status: AVPlayer.TimeControlStatus) {
        switch status {
        case .paused:
            isPlaying = false
        case .playing:
            isPlaying = true
        default:
            break
        }
        
        onMainQueueResultHandler?( .setPlayerViewPlayState(isPlaying) )
    }
    
    func handleDidPlayToEndTime(video: ShortsVideo?) {
        onMainQueueResultHandler?( .setTimeIndicatorLineVisible(false) )
        shortsVideo.seekTo(time: cropTime.start)
        onMainQueueResultHandler?( .resetTimeIndicatorLine )
        
    }
    
}
extension SLVideoEditorViewReactor : SLVideoEditorSliderViewDelegate {
    
    func updateCropTime(start: CMTime, end: CMTime) {
        self.cropTime.start = start
        self.cropTime.end = end
        self.isCropTimeUpdated = true
        
        resultHandler?( .setPlayerEndBoundaryTime(end) )
    }
    
    func seekTo(time: CMTime, handleType: SLVideoEditorSliderHandleType) {
        self.pause()
        onMainQueueResultHandler?( .seekTo(time) )
        onMainQueueResultHandler?( .setTimeIndicatorLineVisible(false) )
        onMainQueueResultHandler?( .resetTimeIndicatorLine )
    }
}
extension SLVideoEditorViewReactor : SLVideoEditorPlayerViewDelegate {
    func updateCropRect(frame: CGRect) {
        self.cropRect = frame
    }
    
    func didTapPlayerView() {
        if isCropTimeUpdated {
            onMainQueueResultHandler?( .seekTo(cropTime.start) )
            isCropTimeUpdated = false
        }
        
        if isPlaying {
            self.pause()
            onMainQueueResultHandler?( .setTimeIndicatorLineVisible(false) )
        }
        else {
            self.play()
            onMainQueueResultHandler?( .setTimeIndicatorLineVisible(true) )
        }
    }
}
