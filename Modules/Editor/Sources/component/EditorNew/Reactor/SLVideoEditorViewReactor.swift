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
        
        case requestToggleVideoPlayOrPause
        case didPlayToEndTime
        case timeControlStatusUpdated(AVPlayer.TimeControlStatus)
        case videoTimeUpdated(Double)
        case setFilterConfig(SLFilterConfig?)
        
        case requestShowCreateTextView
    }
    
    enum Result {
        case updateConvertPercentage(Int)
        case setShortsVideo(ShortsVideo)
        case seekTo(CMTime)
        
        case setFilterBtnVisible(Bool)
        case setPlayBtnVisible(Bool)
        case setLoadingVisible(Bool)
        case resetLoadingProgress
        case setNextButtnEnable(Bool)
        case showUploadInfoViewController(UIViewController)
        case presentViewController(UIViewController)
        case setTimeIndicatorLineVisible(Bool)
        case setTimeIndicatorLineTime(Float)
        case resetTimeIndicatorLine
        
        case setPlayerEndBoundaryTime(CMTime)
        case popView
        case popViewWithMessage
        case showAlert(UIAlertController)
        
        
        case playVideo
        case pauseVideo
        
        case setFilterConfig(String)
        
        case addFFmpegTextBox(ShopLiveFFmpegTextBox)
    }
    
    
    private var temporaryUploadInfo: SLUploadAttachmentInfo?
    private var textBoxList : [ShopLiveFFmpegTextBox] = []
    private var ffmpegTextInfo : FFMpegTextInfo?
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
    private var filterConfig : SLFilterConfig? = nil
    private weak var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    private weak var videoEditorDelegate : ShopLiveVideoEditorDelegate?
    
    
    var resultHandler: ((Result) -> ())?
    var onMainQueueResultHandler : ((Result) -> ())?
    
    
    init(shortsVideo : ShortsVideo){
        self.shortsVideo = shortsVideo
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
        case .requestShowCreateTextView:
            self.onRequestShowCreateTextView()
        }
        
    }
    
    private func resetDataOnViewRotation() {
        cropTime = (.zero, .zero)
        cropRect = .zero
        onViewDidLoad()
        
    }
    
    
    private func onViewDidLoad(){
        
        onMainQueueResultHandler?( .setFilterBtnVisible(ShopLiveShortformEditorFilterListManager.shared.isFilterExist) )
        if let duration = shortsVideo.player?.currentItem?.duration {
            resultHandler?( .setShortsVideo(shortsVideo) )
            
            
            
            let seconds = CMTimeGetSeconds(duration)
            var initialEndTime : CGFloat = 0
            let maxVideoTrimTime = globalConfig.shared.videoTrimOption.maxVideoDuration
            initialEndTime = seconds >= maxVideoTrimTime ? maxVideoTrimTime : seconds
            
            if seconds.isNaN == false {
                cropTime.start = CMTime(seconds: 0, preferredTimescale: 44100)
                cropTime.end = CMTime(seconds: initialEndTime , preferredTimescale: 44100)
            }
            else {
                let seconds = shortsVideo.getVideoDuration()
                initialEndTime = seconds >= maxVideoTrimTime ? maxVideoTrimTime : seconds
                cropTime.start = CMTime(seconds: 0, preferredTimescale: 44100)
                cropTime.end = CMTime(seconds: initialEndTime , preferredTimescale: 44100)
            }
            
            resultHandler?( .setPlayerEndBoundaryTime(cropTime.end) )
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
        
        setFFmpegTextInfo()
        
        let videoInfo = SLVideoInfo(videoPath: videoUrl,
                                    cropRect: cropRect,
                                    videoSize: videoSize,
                                    timeRange: (startTime, endTime),
                                    fileName: (videoUrl as NSString).lastPathComponent,
                                    filterConfig: self.filterConfig,
                                    ffmpegTextInfo: self.ffmpegTextInfo)
        
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
            onMainQueueResultHandler?( .pauseVideo )
            onMainQueueResultHandler?(.popView)
        }
    }
    
    private func onDidPlayToEndTime() {
        onMainQueueResultHandler?( .setTimeIndicatorLineVisible(false) )
        onMainQueueResultHandler?( .seekTo(cropTime.start))
        onMainQueueResultHandler?( .resetTimeIndicatorLine )
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
        
//        for textBox in textBoxList {
//            textBox.setViewHiddenByTimeRange(currentTime: CMTime(seconds: time, preferredTimescale: 44100))
//        }
        
    }
    
    private func onSetFilterConfig(filterConfig : SLFilterConfig?){
        self.filterConfig = filterConfig
    }
    
    private func setFFmpegTextInfo() {
        guard let textView = self.textBoxList.first else { return }
        guard let position = textView.getPosition() else { return }
        guard let timeRange = textView.getTimeRange() else { return }
        let info = FFMpegTextInfo(text: textView.getText(),
                                  textColor: textView.getTextColor(),
                                  textSize: textView.getTextFontSize(),
                                  frame: position,
                                  textBackgroundColor: textView.getTextBackgroundColor(),
                                  timeRange: timeRange)
        
        self.ffmpegTextInfo = info
    }
    
    private func onRequestShowCreateTextView() {
//        let vc = SLFFmpegTextCreateViewController()
//        vc.modalTransitionStyle = .coverVertical
//        vc.modalPresentationStyle = .fullScreen
//        vc.delegate = self 
//        self.onMainQueueResultHandler?( .presentViewController(vc) )
        
        let vc = SLFFmpegTestCreateYTVersionViewController()
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .overCurrentContext
        self.onMainQueueResultHandler?( .presentViewController(vc) )
    }
}
extension SLVideoEditorViewReactor : SLFFMpegTextViewControllerDelegate {
    func onSLFFMpgetTextViewComplete(textInfo : SLFFmpegTextCreateViewReactor.TextInfo) {
        let textBox = ShopLiveFFmpegTextBox()
        textBox.setText(text: textInfo.text)
        textBox.setFontSize(size: textInfo.fontSize)
        textBox.setTextColor(color: textInfo.textColor)
        textBox.setTextBackgroundColor(color: textInfo.textBackgroundColor)
        textBox.setTimeRange(timeRange: textInfo.timeRange)
        onMainQueueResultHandler?( .addFFmpegTextBox(textBox))
        textBoxList.append(textBox)
    }
}
extension SLVideoEditorViewReactor {
    func getVideoUrl() -> URL {
        return shortsVideo.videoUrl
    }
    
    func getVideoSize() -> CGSize? {
        return shortsVideo.getVideoSize()
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
extension SLVideoEditorViewReactor : SLVideoEditorSliderViewDelegate {
    
    func updateCropTime(start: CMTime, end: CMTime) {
        self.cropTime.start = start
        self.cropTime.end = end
        self.isCropTimeUpdated = true
        
        resultHandler?( .setPlayerEndBoundaryTime(end) )
    }
    
    func seekTo(time: CMTime, handleType: SLVideoEditorSliderHandleType) {
        onMainQueueResultHandler?( .pauseVideo )
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
            onMainQueueResultHandler?( .pauseVideo )
        }
        else {
            onMainQueueResultHandler?( .playVideo )
            onMainQueueResultHandler?( .setTimeIndicatorLineVisible(true) )
        }
    }
}
