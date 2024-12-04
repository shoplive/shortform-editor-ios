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
    private let design = ShopLiveShortformEditor.EditorMainConfig.global
    
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
        case setIsCreateShortform(Bool)
        
        case setCropRect(CGRect)
        
        case resetDataOnViewRotation
        
        case requestToggleVideoPlayOrPause
        case didPlayToEndTime
        case timeControlStatusUpdated(AVPlayer.TimeControlStatus)
        case videoTimeUpdated(Double)
        case setFilterConfig(SLFilterConfig?)
        //        case checkIfNextStepIsAvailable
        
        case applyVideoConfiChange(VideoConfigApplyType)
        case setEditingMode(SLVideoEditorMainViewController.ControlBoxType)
        
        case processConvertVideo
        
        case backBtnTapped
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
        case setVideoSoundResult(CGFloat)
        
        
        
        
        case setCropBtnIsSelected(isSelected: Bool)
        case setCropViewIsHidden(Bool)//쓸지 안쓸지 결정중
        case setVideoSoundBtnIsSelected(isSelected : Bool)
        case setVideoSpeedBtnIsSelected(isSelected : Bool)
        case setFilterBtnVisible(Bool)
        case setFilterBtnIsSelected(isSelected : Bool)
        
        case showThumbnailViewController
        
        case showPopUp(UIView)
        case showCancelToast
        
        case updateLoadingPercent(String)
        case showLoadingView
        case cancelLoading
        case didFinishLoading
        case requestPopView
        
        case uploadSuccess(result : ShopLiveEditorResultInternalData?)
        case convertFinished(videoPath : String)
        case onError(ShopLiveCommonError)
    }
    
    private var videoEditInfoDto : SLVideoEditInfoDTO
    private var isPlaying : Bool = false
    private var isCropTimeUpdated : Bool = false
    private var isViewAppeared : Bool = false
    private var isCreateShortform : Bool = true
    
    private let videoConverter = SLVideoConverter()
    private var imageGenerator : AVAssetImageGenerator
    private var imageGeneratorQueue = DispatchQueue(label: "shopLiveImageGeneratorQueue",qos: .background)
    private var currentEditingMode : SLVideoEditorMainViewController.ControlBoxType = .main
    
    private var shortformUploadableResponseData : SLUploadableResponse?
    
    //shortform/video API 경우 긴거 올릴때 중간에 메모리가 유실되는 경우가 있어서 레퍼런스를 잡고 있어야 함
    private var shortformVideoAPI : SLShortformVideoAPI?
    
    var resultHandler: ((Result) -> ())?
    var onMainQueueResultHandler : ((Result) -> ())?
    
    init(shortsVideo : ShortsVideo){
        videoEditInfoDto = SLVideoEditInfoDTO(shortsVideo: shortsVideo)
        let asset = AVAsset(url: shortsVideo.localAbsoluteUrl)
        self.imageGenerator = AVAssetImageGenerator(asset: asset )
        self.imageGenerator.appliesPreferredTrackTransform = true
        self.imageGenerator.maximumSize = CGSize(width: 720, height: 1280)
        self.imageGenerator.apertureMode = .cleanAperture
        super.init()
        videoConverter.delegate = self
    }
    
    deinit {
        ShopLiveLogger.memoryLog("SLVideoEditorViewReactor deinited")
    }
    
    func action(_ action: Action) {
        switch action {
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
        case .setIsCreateShortform(let isCreateShortform):
            onSetIsCreateShortform(isCreateShortform : isCreateShortform)
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
        case .processConvertVideo:
            self.onProcessConvertVideo()
        case .applyVideoConfiChange(let type):
            self.onApplyVideoConfigChanges(type : type)
        case .setEditingMode(let mode):
            self.onSetEditingMode(mode : mode)
        case .backBtnTapped:
            self.onBackBtnTapped()
        }
    }
    
    private func resetDataOnViewRotation() {
        videoEditInfoDto.cropTime = (.zero, .zero)
        videoEditInfoDto.realVideoCropRect = .zero
        onViewDidLoad()
    }
    
    private func onViewDidLoad(){
        onMainQueueResultHandler?( .setFilterBtnVisible(ShopLiveShortformEditorFilterListManager.shared.isFilterExist) )
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
    
    private func onSetIsCreateShortform(isCreateShortform : Bool) {
        self.isCropTimeUpdated = isCreateShortform
    }
    
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
    
    private func onProcessConvertVideo() {
        self.processVideoConvert()
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
        
        if type == .volume {
            onMainQueueResultHandler?( .setVideoSoundResult(CGFloat(videoInfo.volume)) )
        }
    }
    
    private func onSetEditingMode(mode : SLVideoEditorMainViewController.ControlBoxType) {
        self.currentEditingMode = mode
    }
    
    private func onBackBtnTapped() {
        onMainQueueResultHandler?( .requestPopView )
    }
}
//MARK: - GETTER
extension SLVideoEditorMainViewReactor {
    func getVideoUrl() -> URL {
        return videoEditInfoDto.shortsVideo.localAbsoluteUrl
    }
    
    func getVideoSize() -> CGSize? {
        return videoEditInfoDto.shortsVideo.getVideoSize()
    }
    
    func getVideoEditInfoDto() -> SLVideoEditInfoDTO {
        return videoEditInfoDto
    }
    
    func getCurrentEditingMode() -> SLVideoEditorMainViewController.ControlBoxType {
        return self.currentEditingMode
    }
}
extension SLVideoEditorMainViewReactor : SLVideoConverterDelegate {
    private func processVideoConvert() {
        guard let videoSize = videoEditInfoDto.shortsVideo.getVideoSize(),
              let startTime = videoEditInfoDto.cropTime.start.timeSeconds_SL,
              let endTime = videoEditInfoDto.cropTime.end.timeSeconds_SL,
              startTime < endTime else { return }
        let videoUrl = videoEditInfoDto.shortsVideo.localRelativeUrl.absoluteString
        
        let videoInfo = SLVideoInfo(videoPath: videoUrl,
                                    cropRect: videoEditInfoDto.realVideoCropRect,
                                    videoSize: videoSize,
                                    timeRange: (startTime,endTime),
                                    fileName: (videoUrl as NSString).lastPathComponent,
                                    filterConfig: videoEditInfoDto.filterConfig,
                                    volume: Double(videoEditInfoDto.volume),
                                    speed: videoEditInfoDto.videoSpeed)
        
        self.onMainQueueResultHandler?( .updateLoadingPercent("0%") )
        self.onMainQueueResultHandler?( .showLoadingView )
        
        videoConverter.convertVideo(videoInfo: videoInfo) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .Success(let videoPath):
                self.videoEditInfoDto.convertedVideoPath = videoPath
                self.resultHandler?( .convertFinished(videoPath: videoPath) )
                if self.isCreateShortform {
                    self.callShortformUploadableAPI()
                }
            case .Failed(let error):
                let e = ShopLiveCommonErrorGenerator.generateError(errorCase: .FailedEncoding, error: error, message: nil)
                resultHandler?( .onError(e) )
            }
        }
    }
    
    func updateConvertPercent(percent: Int) {
        let value = min(percent,100)
        onMainQueueResultHandler?( .updateLoadingPercent("\(value)%") )
    }
}
extension SLVideoEditorMainViewReactor : SLLoadingAlertControllerDelegate {
    func didCancelLoading() {
        let popUp = SLCustomAlertBox(title: ShopLiveShortformEditorSDKStrings.Editor.Alert.Encoding.Cancel.Title.shoplive, confirmTitle: nil, closeTitle: nil)
        popUp.setBoxCornerRadius(cornerRadius: design.cancelPopupCornerRadius)
        popUp.setButtonCornerRadius(cornerRadius: design.cancelPopupButtonCornerRadius)
        popUp.setCloseButtonDesign(backgroundColor: design.cancelPopupCloseButtonBackgroundColor,
                                   textColor: design.cancelPopupCloseButtonTextColor)
        popUp.setConfirmButtonDesign(backgroundColor: design.cancelPopupConfirmButtonBackgroundColor,
                                     textColor: design.cancelPopupConfirmButtonTextColor)
        popUp.btnClickCallback = { [weak self] result in
            guard let self = self else { return }
            if result == .yes {
                self.onMainQueueResultHandler?( .cancelLoading )
                self.videoConverter.cancelConvert()
                popUp.isHidden = true
                popUp.removeFromSuperview()
                resultHandler?( .showCancelToast )
            }
            else {
                self.onMainQueueResultHandler?( .showLoadingView )
            }
        }
        onMainQueueResultHandler?( .showPopUp(popUp) )
    }
    
    func didFinishLoading() {
        resultHandler?( .didFinishLoading )
    }
}
//MARK: - upload process
extension SLVideoEditorMainViewReactor {
    private func callShortformUploadableAPI() {
        resultHandler?( .showLoadingView )
        ShortFormUploadConfigurationInfosManager.shared.callShortsConfigurationAPI { [weak self] result  in
            guard let self = self else { return }
            SLShortformUploadableAPI().request { result in
                switch result {
                case .success(let data):
                    self.shortformUploadableResponseData = data
                    self.checkThumbnailImage()
                    break
                case .failure(let error):
                    self.resultHandler?( .onError(error) )
                    self.resultHandler?( .didFinishLoading )
                }
            }
        }
    }
    
    private func checkThumbnailImage() {
        let videoStartTime = CMTimeGetSeconds(self.videoEditInfoDto.cropTime.start)
        self.getExtractThumbnail(at: videoStartTime) { [weak self] image  in
            self?.callShortformVideoAPI(image: image)
        }
    }
    
    private func getExtractThumbnail(at targetSec : Double, completion : @escaping(UIImage?) -> ()) {
        imageGeneratorQueue.sync { [weak self] in
            guard let self = self else { return }
            let time = CMTime(seconds: targetSec, preferredTimescale: 44100)
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                completion(UIImage.init(cgImage: cgImage))
            }
            catch(_) {
                completion(nil)
            }
        }
    }
    
    private func callShortformVideoAPI(image : UIImage?) {
        guard let apiEndpoint = self.shortformUploadableResponseData?.uploadApiEndpoint,
              let sessionSecret = self.shortformUploadableResponseData?.sessionSecret,
              let videoPath = self.videoEditInfoDto.convertedVideoPath else { return }
        
        self.shortformVideoAPI = SLShortformVideoAPI(apiEndpoint: apiEndpoint, image: nil, video: videoPath, imageData : image, sessionSecret: sessionSecret)
        
        ShortFormUploadConfigurationInfosManager.shared.callShortsConfigurationAPI { [weak self] result in
            guard let self = self else  { return }
            self.shortformVideoAPI?
                .upload { result  in
                    switch result {
                    case .success(let data):
                        self.callShortformRegisterAPI(videoId: data.videoID , imageUrl: data.thumbnailImageURL)
                    case .failure(let error):
                        self.resultHandler?( .onError(error) )
                        self.resultHandler?( .didFinishLoading )
                    }
                }
        }
    }
    
    private func callShortformRegisterAPI(videoId : String, imageUrl : String?){
        ShortFormUploadConfigurationInfosManager.shared.callShortsConfigurationAPI { [weak self] result in
            guard let self = self else { return }
            SLShortformRegisterAPI(parameters: self.makeShortsJson(videoId: videoId, imageUrl: imageUrl)).request { result in
                switch result {
                case .success(let response):
                    let resultData = ShopLiveEditorResultInternalData(shortsId: response.shortsId,
                                                                      localVideoUrl: self.videoEditInfoDto.convertedVideoPath,
                                                                      remoteOriginVideoUrl: response.cards?.first?.originVideoUrl,
                                                                      remoteCoverImageUrl: response.cards?.first?.screenshotUrl,
                                                                      localCoverImage: nil,
                                                                      width: self.videoEditInfoDto.getConvertedVideoSize()?.width,
                                                                      height: self.videoEditInfoDto.getConvertedVideoSize()?.height,
                                                                      duration : self.videoEditInfoDto.getConvertedVideoDuration())
                    
                    self.resultHandler?( .uploadSuccess(result: resultData) )
                    break
                case .failure(let error):
                    self.resultHandler?( .onError(error) )
                    break
                }
                self.onMainQueueResultHandler?( .didFinishLoading )
            }
        }
    }
    
    private func makeShortsJson(videoId : String,imageUrl : String?) -> [String : Any] {
        var shortsDict : [String : Any] = [:]
        
        var cardsDict : [String : Any] = [:]
        cardsDict["cardType"] = "VIDEO"
        cardsDict["source"] = "media"
        cardsDict["videoId"] = videoId
        if let imageUrl = imageUrl {
            cardsDict["specifiedScreenshotUrl"] = imageUrl
        }
        
        var shortsDetailDict : [String : Any] = [:]
        //        shortsDetailDict["description"] = "ios_seeker_thumbnail_test_2_description"
        //        shortsDetailDict["tags"] = ["ios_test_tag1","ios_test_tag2"]
        //        shortsDetailDict["title"] = "ios_upload_test \(Date())"
        shortsDict["cards"] = [cardsDict]
        shortsDict["shortsDetail"] = shortsDetailDict
        shortsDict["shortsType"] = "CARD"
        
        var creator : [String : Any] = [:]
        
        if let user = ShopLiveCommon.getUser() {
            creator["userId"] = user.userId
            if let displayUserId = user.custom?["displayUserId"] as? String {
                creator["displayUserId"] = displayUserId
            }
            if let userName = user.userName {
                creator["userName"] =  userName
            }
            if let profileImage = user.custom?["profileImage"] as? String {
                creator["profileImage"] = profileImage
            }
        }
        
        if creator.isEmpty == false {
            return ["shorts" : shortsDict, "shortsStatus" : "OPENED", "creator" : creator , "startAt" : Int64(Date().timeIntervalSince1970 * 1000) ]
        }
        else {
            return ["shorts" : shortsDict, "shortsStatus" : "OPENED", "startAt" : Int64(Date().timeIntervalSince1970 * 1000) ]
        }
    }
    
    private func removeVideoFile(){
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self, let videoUrl = self.videoEditInfoDto.convertedVideoPath else { return }
            try? FileManager.default.removeItem(atPath: videoUrl)
        }
    }
}
