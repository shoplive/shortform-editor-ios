//
//  ShopLiveCoverPickerReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/5/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit

class ShopLiveCoverPickerReactor : NSObject, SLReactor {
    private let config = ShopLiveEditorConfigurationManager.shared
    
    enum Mode {
        case video
        case photo
    }
    
    enum Action {
        case viewDidLoad
        case viewDidLayoutSubView
        case viewDidAppear
        case seekTo(CMTime)
        
        case setShopLiveCoverPickerData(ShopLiveCoverPickerData?)
        case setVideoEditInfo(SLVideoEditInfoDTO?)
        case setVideoUrl(URL)
        case requestOnConfirm
        case setCurrentMode(Mode)
        case setCropImageResultFromCropableImageView(UIImage?)
        case setPlayerContainerBound(CGRect)
        case setEditorResultData(ShopLiveEditorResultInternalData?)
        
    }
    
    enum Result {
        case requestShowLoading
        case canceLoading
        case didFinishLoading
        case dismissPhotoPicker
        case setThumbnail(UIImage)
        case requestCropImageForCropableImageView
        case requestNormalImageForCropableImageView
        case videoThumbnailResult(UIImage?)
        case requestFinishCoverPicker
        case onError(ShopLiveCommonError)
        case uploadSuccess(result : ShopLiveEditorResultInternalData?)
        case onEvent(name : EventTrace, payload : [String : Any]?)
    }
    
    private var videoUrl : URL?
    private var videoAsset : AVAsset?
    private var avPlayer : AVPlayer?
    private var currentSeekTime : CMTime = .zero
    private var videoCropRect : CGRect?
    private var playerContainerBound : CGRect?
    private var imageGenerator : AVAssetImageGenerator?
    private var imageGeneratorQueue = DispatchQueue(label: "shopLiveImageGeneratorQueue",qos: .background)
    private var cropImageResultFromCropableImageView : UIImage?
    private var shopliveCoverPickerData : ShopLiveCoverPickerData?
    private var editorResultData : ShopLiveEditorResultInternalData?
    private var videoEditInfo : SLVideoEditInfoDTO?
    
    private var isViewAppeared : Bool = false
    private var blockInitialCropInViewDidLayoutSubView : Bool = false
    private var glkViewSize : CGSize = .zero
    private var currentMode : Mode = .video
    
    private var shortformThumbnailAPI : SLShortformThumbnailAPI?
    
    var resultHandler: ((Result) -> ())?
   
    override init() {
        super.init()
    }
    
    deinit {
        ShopLiveLogger.memoryLog("ShopLiveCoverPickerReactor deinit")
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewDidLoad:
            self.onViewDidLoad()
        case .viewDidAppear:
            self.onViewDidAppear()
        case .viewDidLayoutSubView:
            self.onViewDidLayoutSubView()
        case .setShopLiveCoverPickerData(let data):
            self.onSetShopLiveCoverPickerData(data : data )
        case .setVideoEditInfo(let videoEditInfo):
            self.onSetVideoEditInfo(editInfo : videoEditInfo)
        case .setVideoUrl(let videoUrl):
            self.onSetVideoUrl(url: videoUrl)
        case .seekTo(let time):
            self.onSeekTo(time: time)
        case .requestOnConfirm:
            self.onRequestOnConfirm()
        case .setCurrentMode(let mode):
            self.onSetCurrentMode(mode: mode)
        case .setCropImageResultFromCropableImageView(let image):
            self.onSetCropImageResultFromCropableImageView(image: image)
        case .setPlayerContainerBound(let bound):
            self.onSetPlayerContainerBound(bound: bound)
        case .setEditorResultData(let result):
            self.onSetEditorResultData(result : result)
            break
        }
    }
    
    private func onViewDidLoad() {
        
    }
    
    private func onViewDidAppear() {
        
    }
    
    private func onViewDidLayoutSubView() {
        
    }
    
    private func onSetShopLiveCoverPickerData(data : ShopLiveCoverPickerData?) {
        self.shopliveCoverPickerData = data
    }
    
    private func onSetVideoEditInfo(editInfo : SLVideoEditInfoDTO?) {
        self.videoEditInfo = editInfo
    }
    
    private func onSetVideoUrl(url : URL) {
        self.videoUrl = url
        videoAsset = AVURLAsset(url: url)// AVAsset(url: url)
        self.avPlayer = AVPlayer()
        self.avPlayer?.replaceCurrentItem(with: AVPlayerItem(asset: videoAsset!))
        self.imageGenerator = AVAssetImageGenerator(asset: videoAsset!)
        self.imageGenerator?.appliesPreferredTrackTransform = true
        self.imageGenerator?.apertureMode = .cleanAperture
    }
    
    private func onSeekTo(time : CMTime) {
        self.avPlayer?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        self.currentSeekTime = time
    }
    
    private func onRequestOnConfirm() {
        let isCropEnabled = self.config.coverPickerVisibleActionButton.editOptions.contains(where: { $0 == .crop }) ?? false
        if self.currentMode == .video {
            let seconds = CMTimeGetSeconds(currentSeekTime)
            self.getExtractThumbnail(at: seconds) { [weak self] resultImage in
                guard var resultImage = resultImage else { return }
                if let croppedImage = self?.getVideoThumbnailCroppedImage(image: resultImage), isCropEnabled {
                    resultImage = croppedImage
                }
                self?.resultHandler?( .videoThumbnailResult(resultImage))
                if let _ = self?.shopliveCoverPickerData?.shortsId {
                    self?.callShortformThumbnailAPI(image: resultImage)
                }
                else {
                    self?.resultHandler?( .requestFinishCoverPicker )
                }
            }
        }
        else {
            if isCropEnabled {
                resultHandler?( .requestCropImageForCropableImageView )
            }
            else {
                resultHandler?( .requestNormalImageForCropableImageView )
            }
            
        }
    }
    
    private func onSetCurrentMode(mode : Mode) {
        self.currentMode = mode
    }
    
    private func onSetCropImageResultFromCropableImageView(image : UIImage?) {
        self.cropImageResultFromCropableImageView = image
        if let _  = self.shopliveCoverPickerData?.shortsId {
            guard let resultImage = self.cropImageResultFromCropableImageView else { return }
            self.callShortformThumbnailAPI(image: resultImage )
        }
        else {
            self.resultHandler?( .requestFinishCoverPicker )
        }
    }
    
    private func onSetEditorResultData(result : ShopLiveEditorResultInternalData?) {
        self.editorResultData = result
    }
    
    private func onSetPlayerContainerBound(bound : CGRect) {
        self.playerContainerBound = bound
    }
}
extension ShopLiveCoverPickerReactor {
    private func getExtractThumbnail(at targetSec : Double, completion : @escaping(UIImage?) -> ()) {
        guard let imageGenerator = imageGenerator else {
            completion(nil)
            return
        }
        imageGeneratorQueue.sync { [weak self] in
            let time = CMTime(seconds: targetSec, preferredTimescale: 44100)
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                completion(UIImage.init(cgImage: cgImage))
            }
            catch(let error){
                let commonError = ShopLiveCommonErrorGenerator.generateError(errorCase: .UnexpectedError, error: error, message: nil)
                self?.resultHandler?( .onError(commonError) )
                completion(nil)
            }
        }
    }
    
    private func getVideoThumbnailCroppedImage(image : UIImage) -> UIImage? {
        guard let cropRect = self.videoCropRect else {
            return nil
        }
        return self.cropped(image: image, to: cropRect)
    }
    
    private func cropped(image : UIImage, to rect: CGRect) -> UIImage? {
        guard let cgImage = image.cgImage?.cropping(to: rect) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
}
extension ShopLiveCoverPickerReactor : SLPhotosPickerViewControllerDelegate {
    func photoPicker(picker: UIViewController, didSelectVideo absoluteUrl: URL, relativeUrl: URL) {
        
    }
    
    func photoPicker(picker: UIViewController, didSelectImage url: URL) {
        
    }
    
    func photoPickerOnEvent(picker: UIViewController, name: EventTrace, payload: [String : Any]?) {
        
    }
    
    func photoPickerOnEvent(name: EventTrace, payload: [String : Any]?) {
        resultHandler?( .onEvent(name: name, payload: payload))
    }
    
    func photoPicker(didSelectVideo absoluteUrl: URL, relativeUrl: URL) {
        
    }
    
    func photoPicker(didSelectImage url: URL) {
        defer {
            self.currentMode = .photo
            resultHandler?( .dismissPhotoPicker )
        }
        do {
            let data = try Data(contentsOf: url)
            guard let image = UIImage(data: data) else { return }
            resultHandler?( .setThumbnail(image) )
        }
        catch(_) {
        }
    }
    
    func photoPiker(onClose picker: UIViewController) {
        picker.dismiss(animated: true)
    }
}
extension ShopLiveCoverPickerReactor : SLLoadingAlertControllerDelegate {
    func didCancelLoading() {
        resultHandler?( .canceLoading )
    }
    
    func didFinishLoading() {
//        resultHandler?( .didFinishLoading )
    }
}
extension ShopLiveCoverPickerReactor {
    private func callShortformThumbnailAPI(image : UIImage) {
        guard let shortsId = self.shopliveCoverPickerData?.shortsId else { return }
        self.shortformThumbnailAPI = SLShortformThumbnailAPI(image: "image", imageData: image, shortsId: shortsId)
        resultHandler?( .requestShowLoading )
        self.shortformThumbnailAPI?
            .upload { [weak self] result in
                guard let self = self else { return }
                switch result {
                case .success(let response):
                    if var resultData = editorResultData {
                        resultData.localCoverImage = image
                        self.resultHandler?( .uploadSuccess(result: resultData))
                    }
                    else  {
                        let resultData = ShopLiveEditorResultInternalData(shortsId: response.shortsId,
                                                                          localVideoUrl: nil,
                                                                          remoteOriginVideoUrl: response.cards?.first?.originVideoUrl,
                                                                          remoteCoverImageUrl: response.cards?.first?.screenshotUrl,
                                                                          localCoverImage: image,
                                                                          width: response.cards?.first?.width ?? 0.0,
                                                                          height: response.cards?.first?.height ?? 0.0,
                                                                          duration : Double(response.cards?.first?.duration ?? 0))
                        self.resultHandler?( .uploadSuccess(result: resultData) )
                    }
                    self.resultHandler?( .requestFinishCoverPicker )
                    break
                case .failure(let error):
                    self.resultHandler?( .onError(error) )
                    break
                }
                self.resultHandler?( .didFinishLoading )
            }
    }
}
extension ShopLiveCoverPickerReactor {
    func getVideoUrl() -> URL? {
        return videoUrl
    }
    
    func getAVPlayer() -> AVPlayer? {
        return self.avPlayer
    }
    
    func getVideoSize() -> CGSize? {
        guard let track = self.videoAsset?.tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
}
extension ShopLiveCoverPickerReactor : SLVideoEditorPlayerCropViewDelegate {
    func updateCropRect(frame: CGRect) {
        ShopLiveLogger.tempLog("[updateCropRect] \(frame)")
        self.videoCropRect = frame
    }
}
