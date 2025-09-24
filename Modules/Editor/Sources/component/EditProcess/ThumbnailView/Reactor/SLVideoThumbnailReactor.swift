//
//  SLVideoThumbnailReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/13/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit

class SLVideoThumbnailReactor : NSObject, SLReactor {
    private let design = ShopLiveShortformEditor.EditorCoverPickerConfig.global
    private let mainDesign = ShopLiveShortformEditor.EditorMainConfig.global
    
    enum Action {
        case viewDidLoad
        case viewDidLayoutSubView
        case viewDidAppear
        case setShortformEditorDelegate(ShopLiveShortformEditorDelegate?)
        case setVideoEditorDelegate(ShopLiveVideoEditorDelegate?)
        
        
        case timeControlStatusUpdated(AVPlayer.TimeControlStatus)
        case setThumbnailTime(CMTime)
        case requestOnConfirm
        case cancelConverting
        
        case requestAPI
        
    }
    
    enum Result {
        case setThumbnail(UIImage)
        case setShortsVideo(ShortsVideo)
        case seekThumbailSliderTo(CMTime) //재수정하러 들어왔을때,
        case setinitailCropRect(CGRect)
        case seekTo(CMTime)
        case pauseVideo
        case dismissPhotoPicker
        case showLoadingView
        case cancelLoading
        case didFinishLoading
        case updateLoadingPercent(String)
        
        case showPopUp(UIView)
        case showCancelToast
        
        case pushViewController(UIViewController)
        
        case setDummy(UIImage?)
    }
    
    var resultHandler: ((Result) -> ())?
    
    private var videoEditInfoDto : SLVideoEditInfoDTO
    private var videoAsset : AVAsset?
    private var imageGenerator : AVAssetImageGenerator
    private var imageGeneratorQueue = DispatchQueue(label: "shopLiveImageGeneratorQueue",qos: .background)
    private let videoConverter = SLVideoConverter()
    private weak var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    private weak var videoEditorDelegate : ShopLiveVideoEditorDelegate?
    private var isViewAppeared : Bool = false
    private var blockInitialCropInViewDidLayoutSubView : Bool = false
    private var glkViewSize : CGSize = .zero
    private var shortformUploadableResponseData : SLUploadableResponse?
    
    //shortform/video API 경우 긴거 올릴때 중간에 메모리가 유실되는 경우가 있어서 레퍼런스를 잡고 있어야 함
    private var shortformVideoAPI : SLShortformVideoAPI?
    
    
    init(videoEditInfo : SLVideoEditInfoDTO) {
        self.videoEditInfoDto = videoEditInfo
        videoAsset = AVAsset(url: videoEditInfo.shortsVideo.localAbsoluteUrl)
        self.imageGenerator = AVAssetImageGenerator(asset: videoAsset! )
        self.imageGenerator.appliesPreferredTrackTransform = true
        self.imageGenerator.maximumSize = CGSize(width: 720, height: 1280)
        self.imageGenerator.apertureMode = .cleanAperture
        self.imageGenerator.requestedTimeToleranceBefore = .zero
        self.imageGenerator.requestedTimeToleranceAfter = .zero
        super.init()
        videoConverter.delegate = self
    }
    
    deinit {
        ShopLiveLogger.memoryLog("slVideoThumbnailReactor deinit")
    }
    
    func action(_ action: Action) {
        switch action {
        case .setShortformEditorDelegate(let delegate):
            self.shortformEditorDelegate = delegate
        case .setVideoEditorDelegate(let delegate):
            self.videoEditorDelegate = delegate
        case .viewDidLoad:
            self.onViewDidLoad()
        case .viewDidLayoutSubView:
            self.onViewDidLayoutSubviews()
        case .viewDidAppear:
            self.onViewDidAppear()
        case .timeControlStatusUpdated(let status):
            self.onTimeControlStatusUpdated(status: status)
        case .setThumbnailTime(let time):
            self.onSetThumbnailTime(time: time)
        case .requestOnConfirm:
            self.onSetRequestOnConfirm()
        case .cancelConverting:
            videoConverter.cancelConvert()
        case .requestAPI:
            self.callShortformUploadablAPI()
        }
    }
    
    private func onViewDidLoad() {
        resultHandler?( .setShortsVideo(videoEditInfoDto.shortsVideo) )
    }
    
    private func onViewDidLayoutSubviews() {
        if blockInitialCropInViewDidLayoutSubView == false {
            blockInitialCropInViewDidLayoutSubView = true
            self.resultHandler?( .setinitailCropRect(videoEditInfoDto.cropViewRatio) )
        }
    }
    
    private func onViewDidAppear() {
        if isViewAppeared == false {
            if videoEditInfoDto.thumbnailType == .image, let image = videoEditInfoDto.thumbnailImage {
                resultHandler?( .setThumbnail(image) )
            }
            else if videoEditInfoDto.thumbnailType == .video {
                resultHandler?( .seekTo(videoEditInfoDto.thumbnailTime) )
                resultHandler?( .seekThumbailSliderTo(videoEditInfoDto.thumbnailTime) )
            }
            self.resultHandler?( .setinitailCropRect(videoEditInfoDto.cropViewRatio) )
            isViewAppeared = true
        }
    }
    
    private func onTimeControlStatusUpdated(status : AVPlayer.TimeControlStatus) {
        if status == .playing {
            resultHandler?( .pauseVideo )
            resultHandler?( .seekTo(.zero) )
        }
    }
    
    private func onSetThumbnailTime(time : CMTime) {
        videoEditInfoDto.thumbnailTime = time
        self.videoEditInfoDto.thumbnailType = .video
    }
    
    private func onSetRequestOnConfirm() {
        processVideoConvert()
    }
}
//MARK: - GETTER
extension SLVideoThumbnailReactor {
    func getVideoUrl() -> URL {
        return videoEditInfoDto.shortsVideo.localAbsoluteUrl
    }
}
extension SLVideoThumbnailReactor {
    private func processVideoConvert() {
        guard let videoSize = videoEditInfoDto.shortsVideo.getVideoSize(),
              let startTime = videoEditInfoDto.cropTime.start.timeSeconds_SL,
              let endTime = videoEditInfoDto.cropTime.end.timeSeconds_SL,
              startTime < endTime else { return }
        let videoUrl = videoEditInfoDto.shortsVideo.localAbsoluteUrl.path
        
        let videoInfo = SLVideoInfo(videoPath: videoUrl,
                                    cropRect: videoEditInfoDto.realVideoCropRect,
                                    videoSize: videoSize,
                                    timeRange: (startTime,endTime),
                                    fileName: "converted_video",
                                    filterConfig: videoEditInfoDto.filterConfig,
                                    volume: 50,
                                    speed: 1)
        
        self.resultHandler?( .updateLoadingPercent("0%") )
        self.resultHandler?( .showLoadingView )
        videoConverter.convertVideo(videoInfo: videoInfo) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .Success(let videoPath):
                self.videoEditInfoDto.convertedVideoPath = videoPath
                self.resultHandler?( .didFinishLoading )
            case .Failed(let error):
                let e = ShopLiveCommonErrorGenerator.generateError(errorCase: .FailedEncoding, error: error, message: nil)
                self.shortformEditorDelegate?.onShopLiveShortformEditorError?(error: e)
//                self.videoEditorDelegate?.onShopLiveVideoEditorError?(editor: nil, error: e)
            }
        }
    }
    
    private func getExtractThumbnail(at targetSec : Double, completion : @escaping(UIImage?) -> ()) {
        prepareImageGeneratorIfNeeded { [weak self] in
            guard let self = self else { return }
            self.imageGeneratorQueue.async { [weak self] in
                guard let self = self else { return }
                let time1 = CMTime(seconds: targetSec, preferredTimescale: 44100)
                
                if let image = self.tryCopyImage(at: time1, strict: true) {
                    completion(image)
                    return
                }
                
                let time2 = CMTime(seconds: targetSec, preferredTimescale: 600)
                if let image = self.tryCopyImage(at: time2, strict: false) {
                    completion(image)
                    return
                }
                
                completion(nil)
            }
        }
    }

    private func tryCopyImage(at time: CMTime, strict: Bool) -> UIImage? {
        let generator = self.imageGenerator
        if strict == false {
            generator.requestedTimeToleranceBefore = CMTime.positiveInfinity
            generator.requestedTimeToleranceAfter = CMTime.positiveInfinity
        } else {
            generator.requestedTimeToleranceBefore = .zero
            generator.requestedTimeToleranceAfter = .zero
        }
        do {
            let cg = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cg)
        } catch {
            return nil
        }
    }

    private func prepareImageGeneratorIfNeeded(completion: (() -> Void)?) {
        guard let asset = self.videoAsset else {
            completion?()
            return
        }
        
        asset.loadValuesAsynchronously(forKeys: ["tracks","duration"]) { [weak self] in
            guard let self = self else { return }
            var error: NSError?
            let tracks = asset.statusOfValue(forKey: "tracks", error: &error)
            let duration = asset.statusOfValue(forKey: "duration", error: &error)
            
            guard tracks == .loaded || duration == .loaded else {
                completion?()
                return
            }
            
            let generator = AVAssetImageGenerator(asset: asset)
            generator.appliesPreferredTrackTransform = true
            generator.maximumSize = CGSize(width: 720, height: 1280)
            generator.apertureMode = .cleanAperture
            generator.requestedTimeToleranceBefore = .zero
            generator.requestedTimeToleranceAfter = .zero
            self.imageGenerator = generator
            completion?()
        }
    }
}
extension SLVideoThumbnailReactor : SLPhotosPickerViewControllerDelegate {
    func photoPicker(picker: UIViewController, didSelectVideo absoluteUrl: URL, relativeUrl: URL, videoCreationDate: Date?) {
        
    }
    
    func photoPicker(picker: UIViewController, didSelectImage url: URL) {
        
    }
    
    func photoPickerOnEvent(picker: UIViewController, name: EventTrace, payload: [String : Any]?) {
    }
    
    func photoPickerOnEvent(name: EventTrace, payload: [String : Any]?) {
        
    }
    
    func photoPicker(didSelectVideo absoluteUrl: URL, relativeUrl: URL) {
        /** no - op */
    }
    
    func photoPicker(didSelectImage url: URL) {
        defer {
            resultHandler?( .dismissPhotoPicker )
        }
        do {
            let data = try Data(contentsOf: url)
            guard let image = UIImage(data: data) else { return }
            self.videoEditInfoDto.thumbnailType = .image
            self.videoEditInfoDto.thumbnailImage = image
            resultHandler?( .setThumbnail(image) )
        }
        catch(_) {
            
        }
        
    }
    
    func photoPiker(onClose picker: UIViewController) {
        picker.dismiss(animated: true)
    }
}
extension SLVideoThumbnailReactor : SLLoadingAlertControllerDelegate {
    func didCancelLoading() {
        resultHandler?( .cancelLoading )
        
        let popUp = SLCustomAlertBox(title: ShopLiveShortformEditorSDKStrings.Editor.Alert.Encoding.Cancel.Title.shoplive, confirmTitle: nil, closeTitle: nil)
        popUp.setBoxCornerRadius(cornerRadius: mainDesign.popupCornerRadius)
        popUp.setButtonCornerRadius(cornerRadius: mainDesign.popupButtonCornerRadius)
        popUp.setCloseButtonDesign(backgroundColor: mainDesign.popupCloseButtonBackgroundColor, textColor: mainDesign.popupCloseButtonTextColor,
                                   size: mainDesign.popupCloseButtonTextSize, weight: mainDesign.popupCloseButtonTextWeight, customFont: mainDesign.popupCloseButtonTextFont)
        popUp.setConfirmButtonDesign(backgroundColor: mainDesign.popupConfirmButtonBackgroundColor, textColor: mainDesign.popupConfirmButtonTextColor,
                                     size: mainDesign.popupConfirmButtonTextSize, weight: mainDesign.popupConfirmButtonTextWeight, customFont: mainDesign.popupConfirmButtonTextFont)
        popUp.btnClickCallback = { [weak self] result in
            guard let self = self else { return }
            if result == .yes {
                self.videoConverter.cancelConvert()
                popUp.isHidden = true
                popUp.removeFromSuperview()
                resultHandler?( .showCancelToast )
            }
            else {
                self.resultHandler?( .showLoadingView )
            }
        }
        
        resultHandler?( .showPopUp(popUp) )
    }

    func didFinishLoading() {
        resultHandler?( .didFinishLoading )
    }
}
extension SLVideoThumbnailReactor : SLVideoConverterDelegate {
    func updateConvertPercent(percent: Int) {
        let value = min(percent,100)
        resultHandler?( .updateLoadingPercent("\(value)%") )
    }
}
//MARK: - uploadProcess
extension SLVideoThumbnailReactor {
    private func callShortformUploadablAPI() {
        resultHandler?( .showLoadingView )
        ShortFormUploadConfigurationInfosManager.shared.callShortsConfigurationAPI { [weak self] result  in
            guard let self else { return }
            SLShortformUploadableAPI().request {result in
                switch result {
                case .success(let data):
                    self.shortformUploadableResponseData = data
                    self.checkThumbnailImage()
                    break
                case .failure(let error):
//                    self.videoEditorDelegate?.onShopLiveVideoEditorError?(error: error)
                    self.shortformEditorDelegate?.onShopLiveShortformEditorError?(error: error)
                    self.resultHandler?( .didFinishLoading )
                }
            }
        }
    }
    
    private func checkThumbnailImage() {
        if self.videoEditInfoDto.thumbnailType == .image, let image = videoEditInfoDto.thumbnailImage {
            resultHandler?( .setDummy(image))
            self.callShortformVideoAPI(image: image)
        }
        else {
            let thumbnailTime = videoEditInfoDto.thumbnailTime
            self.getExtractThumbnail(at: thumbnailTime.seconds) { [weak self] image  in
                self?.resultHandler?( .setDummy(image))
                self?.callShortformVideoAPI(image: image)
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
                        break
//                        self.callShortformRegisterAPI(videoId: data.videoId ?? -1, imageUrl: data.thumbnailImageUrl)
                    case .failure(let error):
//                        self.videoEditorDelegate?.onShopLiveVideoEditorError?(error: error)
                        self.shortformEditorDelegate?.onShopLiveShortformEditorError?(error: error)
                        self.resultHandler?( .didFinishLoading )
                    }
                }
        }
    }

    private func callShortformRegisterAPI(videoId : Int, imageUrl : String?){
        ShortFormUploadConfigurationInfosManager.shared.callShortsConfigurationAPI { [weak self] result in
            guard let self = self else { return }
            SLShortformRegisterAPI(parameters: self.makeShortsJson(videoId: videoId, imageUrl: imageUrl)).request { result in
                switch result {
                case .success(_):
//                    self.shortformEditorDelegate?.onShopLiveShortformEditorUploadSuccess?(videoPath: "")
                    self.removeVideoFile()
                    break
                case .failure(let error):
//                    self.videoEditorDelegate?.onShopLiveVideoEditorError?(error: error)
                    self.shortformEditorDelegate?.onShopLiveShortformEditorError?(error: error)
                    break
                }
                self.resultHandler?( .didFinishLoading )
            }
        }
    }
    
    
    private func makeShortsJson(videoId : Int,imageUrl : String?) -> [String : Any] {
        var shortsDict : [String : Any] = [:]
        
        var cardsDict : [String : Any] = [:]
        cardsDict["cardType"] = "VIDEO"
        cardsDict["source"] = "media"
        cardsDict["videoId"] = videoId
        if let imageUrl = imageUrl {
            cardsDict["specifiedScreenshotUrl"] = imageUrl
        }
        
        var shortsDetailDict : [String : Any] = [:]
        shortsDetailDict["description"] = "ios_seeker_thumbnail_test_2_description"
        shortsDetailDict["tags"] = ["ios_test_tag1","ios_test_tag2"]
        shortsDetailDict["title"] = "ios_seeker_thumbnail_test_2_title"
        
        
        shortsDict["cards"] = [cardsDict]
        shortsDict["shortsDetail"] = shortsDetailDict
        shortsDict["shortsType"] = "CARD"
        
        return ["shorts" : shortsDict]
    }
    
    private func removeVideoFile(){
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self, let videoUrl = self.videoEditInfoDto.convertedVideoPath else { return }
            try? FileManager.default.removeItem(atPath: videoUrl)
        }
    }
}
