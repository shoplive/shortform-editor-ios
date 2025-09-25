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
    private let videoUploadOption = globalConfig.shared.videoUploadOption
    
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
        case setSpeedRate
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
        case showLoadingView(String)
        case cancelLoading
        case requestPopView
        
        case uploadSuccess(result : ShopLiveEditorResultInternalData?)
        case convertFinished(videoPath : String)
        case onError(ShopLiveCommonError)
    }
    
    private var videoEditInfoDto : SLVideoEditInfoDTO
    private var isPlaying : Bool = false
    private var isCropTimeUpdated : Bool = false
    private var isViewAppeared : Bool = false
    private var isLoading : Bool = false
    private var isUserConvertStop: Bool = false
    private var isUserUploadStop: Bool = false
    
    private let videoConverter = SLVideoConverter()
    private var imageGenerator : AVAssetImageGenerator
    private var imageGeneratorQueue = DispatchQueue(label: "shopLiveImageGeneratorQueue",qos: .background)
    private var currentEditingMode : SLVideoEditorMainViewController.ControlBoxType = .main
    
    private var shortformUploadableResponseData : SLUploadableResponse?
    
    private let appStateObserver = ShopliveAppStateObserver()
    
    //shortform/video API 경우 긴거 올릴때 중간에 메모리가 유실되는 경우가 있어서 레퍼런스를 잡고 있어야 함
    private var shortformVideoAPI : SLShortformVideoAPI?
    private var uploadCancellable : APIDefinitionCancellable?
    
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
        appStateObserver.delegate = self
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
        case .setSpeedRate:
            self.onSetSpeedRate()
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
            
            ShopLiveLogger.tempLog("[SLVideoEditorMainViewController] video Time \(videoEditInfoDto.cropTime.end)")
            
            resultHandler?( .setPlayerEndBoundaryTime(videoEditInfoDto.cropTime.end) )
        }
        else {
            
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
        // Tabber - (2025.04.07) seekTo가 다 끝나지 않은 상태에서 play를 할 경우
        // play 자체가 안먹히는 상황이 발생하여 딜레이를 주었습니다.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
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
    
    private func onSetSpeedRate() {
        onMainQueueResultHandler?( .setSpeedRateResult(videoEditInfoDto.videoSpeed) )
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
        if isLoading {
            showUploadCancelPopUp()
        }
        else {
            onMainQueueResultHandler?( .requestPopView )
        }
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
              startTime < endTime,
              isLoading == false else { return }
        let videoUrl = videoEditInfoDto.shortsVideo.localRelativeUrl.absoluteString
        
        let videoInfo = SLVideoInfo(videoPath: videoUrl,
                                    cropRect: videoEditInfoDto.realVideoCropRect,
                                    videoSize: videoSize,
                                    timeRange: (startTime,endTime),
                                    fileName: "converted_video",
                                    filterConfig: videoEditInfoDto.filterConfig,
                                    volume: Double(videoEditInfoDto.volume),
                                    speed: videoEditInfoDto.videoSpeed)
        
        self.onMainQueueResultHandler?( .updateLoadingPercent("0%") )
        self.onMainQueueResultHandler?( .showLoadingView(ShopLiveShortformEditorSDKStrings.Editor.Loading.compress) )
        
        self.isLoading = true
        self.isUserConvertStop = false
        
        videoConverter.convertVideo(videoInfo: videoInfo) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .Success(let videoPath):
                self.videoEditInfoDto.convertedVideoPath = videoPath
                DispatchQueue.main.async {
                    self.resultHandler?( .convertFinished(videoPath: videoPath) )
                    if self.videoUploadOption.isCreatedShortform {
                        self.callShortformUploadableAPI()
                    }
                    else {
                        self.isLoading = false
                        self.onMainQueueResultHandler?( .cancelLoading )
                    }
                }
            case .Failed(let error):
                ShopLiveLogger.tempLog("processVideoConvert error: \(error)")
                
                var e : ShopLiveCommonError
                
                if let error = error as? SLVideoConvertError {
                    switch error {
                    case .error(let failLog, let allLog):
                        
                        var sendMessage: String = failLog
                        
                        if failLog == "No stack trace" {
                            sendMessage = allLog
                        }
                        
                        e = ShopLiveCommonErrorGenerator.generateError(errorCase: .FailedEncoding, error: error, message: sendMessage)
                    case .cancel(let log):
                        e = ShopLiveCommonErrorGenerator.generateError(errorCase: .FailedEncoding, error: error, message: log)
                        ShopLiveLogger.tempLog("processVideoConvert error not Cancel : \(error)")
                    }
                } else {
                    e = ShopLiveCommonErrorGenerator.generateError(errorCase: .FailedEncoding, error: error, message: nil)
                }
                
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.onMainQueueResultHandler?( .cancelLoading )
                    guard !self.isUserConvertStop else { return }
                    self.resultHandler?( .onError(e) )
                }
            }
        }
    }
    
    func updateConvertPercent(percent: Int) {
        let value = min(percent,100)
        onMainQueueResultHandler?( .updateLoadingPercent("\(value)%") )
    }
}
extension SLVideoEditorMainViewReactor : SLCircularProgressIndicatorViewDelegate {
    
    func didTapLoadingView(_ alertController: SLCircularProgressIndicatorView) {
        if uploadCancellable != nil {
            self.showUploadCancelPopUp()
        } else {
            self.showEncodingCancelPopUp()
        }
    }
    
    private func showEncodingCancelPopUp() {
        let popUp = SLCustomAlertBox(title: ShopLiveShortformEditorSDKStrings.Editor.Alert.Encoding.Cancel.Title.shoplive, confirmTitle: nil, closeTitle: nil)
        popUp.setBoxCornerRadius(cornerRadius: design.popupCornerRadius)
        popUp.setButtonCornerRadius(cornerRadius: design.popupButtonCornerRadius)
        popUp.setCloseButtonDesign(backgroundColor: design.popupCloseButtonBackgroundColor,
                                   textColor: design.popupCloseButtonTextColor,
                                   size: design.popupCloseButtonTextSize,
                                   weight: design.popupCloseButtonTextWeight,
                                   customFont: design.popupCloseButtonTextFont)
        popUp.setConfirmButtonDesign(backgroundColor: design.popupConfirmButtonBackgroundColor,
                                     textColor: design.popupConfirmButtonTextColor,
                                     size: design.popupConfirmButtonTextSize,
                                     weight: design.popupConfirmButtonTextWeight,
                                     customFont: design.popupConfirmButtonTextFont)
        popUp.btnClickCallback = { [weak self] (result: SLCustomAlertBox.ResultType) in
            guard let self = self else { return }
            if result == .yes {
                self.isLoading = false
                self.isUserConvertStop = true
                self.onMainQueueResultHandler?( .cancelLoading )
                self.videoConverter.cancelConvert()
                resultHandler?( .showCancelToast )
            }
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                popUp.alpha = 0
            }, completion: { _ in
                popUp.isHidden = true
                popUp.removeFromSuperview()
            })
        }
        onMainQueueResultHandler?( .showPopUp(popUp) )
    }
    
    private func showUploadCancelPopUp() {
        let popUp = SLCustomAlertBox(title: ShopLiveShortformEditorSDKStrings.Editor.Alert.Uploading.Cancel.Title.shoplive, confirmTitle: nil, closeTitle: nil)
        
        popUp.setBoxCornerRadius(cornerRadius: design.popupCornerRadius)
        popUp.setButtonCornerRadius(cornerRadius: design.popupButtonCornerRadius)
        popUp.setCloseButtonDesign(backgroundColor: design.popupCloseButtonBackgroundColor,
                                   textColor: design.popupCloseButtonTextColor,
                                   size: design.popupCloseButtonTextSize,
                                   weight: design.popupCloseButtonTextWeight,
                                   customFont: design.popupCloseButtonTextFont)
        
        popUp.setConfirmButtonDesign(backgroundColor: design.popupConfirmButtonBackgroundColor,
                                     textColor: design.popupConfirmButtonTextColor,
                                     size: design.popupConfirmButtonTextSize,
                                     weight: design.popupConfirmButtonTextWeight,
                                     customFont: design.popupConfirmButtonTextFont)
        
        popUp.btnClickCallback = { [weak self] (result: SLCustomAlertBox.ResultType) in
            guard let self = self else { return }
            if result == .yes {
                self.isLoading = false
                self.isUserUploadStop = true
                self.onMainQueueResultHandler?( .cancelLoading )
                resultHandler?( .showCancelToast )
                self.uploadCancellable?.cancel()
            }
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                popUp.alpha = 0
            }, completion: { _ in
                popUp.isHidden = true
                popUp.removeFromSuperview()
            })
            
        }
        onMainQueueResultHandler?( .showPopUp(popUp) )
    }
}
//MARK: - upload process
extension SLVideoEditorMainViewReactor {
    private func callShortformUploadableAPI() {
        onMainQueueResultHandler?( .updateLoadingPercent("0%"))
        onMainQueueResultHandler?( .showLoadingView(ShopLiveShortformEditorSDKStrings.Editor.Loading.thumbnail) )
        ShortFormUploadConfigurationInfosManager.shared.callShortsConfigurationAPI { [weak self] result  in
            guard let self = self else { return }
            SLShortformUploadableAPI().request { result in
                switch result {
                case .success(let data):
                    self.onMainQueueResultHandler?( .updateLoadingPercent("100%"))
                    self.shortformUploadableResponseData = data
                    self.checkThumbnailImage()
                    break
                case .failure(let error):
                    self.resultHandler?( .onError(error) )
                    self.isLoading = false
                    self.resultHandler?( .cancelLoading )
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
            
            if #available(iOS 16.0, *) {
                Task {
                    do {
                        let (cgImage, _) = try await self.imageGenerator.image(at: time)
                        completion(UIImage(cgImage: cgImage))
                    } catch {
                        self.resultHandler?(.onError(.init(code: 60001, message: "getExtractThumbnail iOS 16 Upper Error", error: error)))
                        completion(nil)
                    }
                }
            } else {
                do {
                    let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                    completion(UIImage.init(cgImage: cgImage))
                }
                catch {
                    self.resultHandler?(.onError(.init(code: 60002, message: "getExtractThumbnail iOS 16 Under Error", error: error)))
                    completion(nil)
                }
            }
        }
    }
    
    private func callShortformVideoAPI(image : UIImage?) {
        guard let apiEndpoint = self.shortformUploadableResponseData?.uploadApiEndpoint,
              let sessionSecret = self.shortformUploadableResponseData?.sessionSecret,
              let videoPath = self.videoEditInfoDto.convertedVideoPath,
              let videoDuration = self.videoEditInfoDto.getConvertedVideoDuration() else {
            
            resultHandler?(.onError(.init(code: 60003, message: """
callShortformVideoAPI data is nil
        apiEndpoint : \(String(describing: self.shortformUploadableResponseData?.uploadApiEndpoint))
        sessionSecret : \(String(describing: self.shortformUploadableResponseData?.sessionSecret))
        videoPath : \(String(describing: self.videoEditInfoDto.convertedVideoPath))
        videoDuration : \(String(describing: self.videoEditInfoDto.getConvertedVideoDuration)) 
""", error: nil)))
            
            return
        }
        
        onMainQueueResultHandler?(.updateLoadingPercent("0%"))
        onMainQueueResultHandler?(.showLoadingView(ShopLiveShortformEditorSDKStrings.Editor.Loading.upload))
        isUserUploadStop = false
        
        if #available(iOS 16.0, *) {
            Task {
                do {
                    let size = try await self.videoEditInfoDto.getConvertedVideoSizeAsync()
                    
                    shortformUpload(
                        apiEndpoint: apiEndpoint,
                        videoPath: videoPath,
                        image: image,
                        videoWidth: size?.width,
                        videoHeight: size?.height,
                        videoDuration: videoDuration,
                        sessionSecret: sessionSecret
                    )
                } catch {
                    await MainActor.run { [weak self] in
                        self?.resultHandler?(.onError(.init(code: 60004, message: "getConvertedVideoSizeAsync error", error: error)))
                    }
                    
                }
            }
        } else {
            let videoWidth = self.videoEditInfoDto.getConvertedVideoSize()?.width
            let videoHeight = self.videoEditInfoDto.getConvertedVideoSize()?.height
            
            shortformUpload(
                apiEndpoint: apiEndpoint,
                videoPath: videoPath,
                image: image,
                videoWidth: videoWidth,
                videoHeight: videoHeight,
                videoDuration: videoDuration,
                sessionSecret: sessionSecret
            )
        }
        
    }
    
    private func shortformUpload(apiEndpoint: String, videoPath: String, image: UIImage?, videoWidth: CGFloat? = nil, videoHeight: CGFloat? = nil, videoDuration: Double, sessionSecret: String) {
        self.shortformVideoAPI = SLShortformVideoAPI(
            apiEndpoint: apiEndpoint,
            image: nil,
            video: videoPath,
            imageData : image,
            sessionSecret: sessionSecret,
            videoWidth: videoWidth,
            videoHeight: videoHeight,
            videoDuration: videoDuration
        )
        
        ShortFormUploadConfigurationInfosManager.shared.callShortsConfigurationAPI { [weak self] result in
            guard let self = self else  { return }
            self.uploadCancellable = self.shortformVideoAPI?
                .upload { result in
                    self.uploadCancellable = nil
                    switch result {
                    case .success(let data):
                        self.callShortformRegisterAPI(videoId: data.videoID , imageUrl: data.thumbnailImageURL)
                    case .failure(let error):
                        self.isLoading = false
                        self.resultHandler?( .cancelLoading )
                        
                        guard !self.isUserUploadStop else { return }
                        self.resultHandler?( .onError(error) )
                    }
                } progressHandler: { [weak self] value in
                    let percent = Int(round(Double(value) * 100))
                    self?.onMainQueueResultHandler?(.updateLoadingPercent("\(percent)%"))
                }
        }
    }
    
    private func callShortformRegisterAPI(videoId : String, imageUrl : String?){
        ShortFormUploadConfigurationInfosManager.shared.callShortsConfigurationAPI { [weak self] result in
            guard let self = self else { return }
            
            ShopLiveLogger.tempLog("[SLVideoEditorMainViewReactor] self.makeShortsJson(videoId: videoId, imageUrl: imageUrl) \(self.makeShortsJson(videoId: videoId, imageUrl: imageUrl))")
            
            SLShortformRegisterAPI(parameters: self.makeShortsJson(videoId: videoId, imageUrl: imageUrl)).request { result in
                switch result {
                case .success(let response):
                    
                    ShopLiveLogger.tempLog("[SLVideoEditorMainViewReactor] originSLShortsModel \(response.dictionary_SL)")
                    
                    let resultData = ShopLiveEditorResultInternalData(shortsId: response.shortsId,
                                                                      localVideoUrl: self.videoEditInfoDto.convertedVideoPath,
                                                                      remoteOriginVideoUrl: response.cards?.first?.originVideoUrl,
                                                                      remoteCoverImageUrl: response.cards?.first?.screenshotUrl,
                                                                      localCoverImage: nil,
                                                                      width: self.videoEditInfoDto.getConvertedVideoSize()?.width,
                                                                      height: self.videoEditInfoDto.getConvertedVideoSize()?.height,
                                                                      duration : self.videoEditInfoDto.getConvertedVideoDuration(),
                                                                      videoCreatedAt: ShopLiveShortformEditorDataStorage.shared.mediaPickerVideoCreationDate)
                    
                    self.resultHandler?( .uploadSuccess(result: resultData) )
                    break
                case .failure(let error):
                    self.resultHandler?( .onError(error) )
                    break
                }
                self.isLoading = false
                self.onMainQueueResultHandler?( .cancelLoading )
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
            shortsDetailDict["creator"] = creator
        }
    
        //shortsDetailDict["description"] = "ios_seeker_thumbnail_test_2_description"
        //shortsDetailDict["tags"] = ["ios_test_tag1","ios_test_tag2"]
        //shortsDetailDict["title"] = "ios_upload_test \(Date())"
        shortsDict["cards"] = [cardsDict]
        shortsDict["shortsDetail"] = shortsDetailDict
        shortsDict["shortsType"] = "CARD"
        
        return ["shorts" : shortsDict, "shortsStatus" : videoUploadOption.shortsStatus.rawValue, "startAt" : Int64(Date().timeIntervalSince1970 * 1000) ]
    }
    
    private func removeVideoFile(){
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self, let videoUrl = self.videoEditInfoDto.convertedVideoPath else { return }
            try? FileManager.default.removeItem(atPath: videoUrl)
        }
    }
}
extension SLVideoEditorMainViewReactor : ShopliveAppStateObserverDelegate {
    func handleAppStateNotification(appState: SLAppState) {
        switch appState {
        case .willEnterBackground, .didEnterBackground:
            self.handleAppWillDidEnterbackground()
        default:
            break
        }
    }
    
    private func handleAppWillDidEnterbackground() {
        onMainQueueResultHandler?( .pauseVideo )
    }
}
