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
        case setVideoUrl(URL)
        case requestOnConfirm
        case setCurrentMode(Mode)
        case setCropImageResultFromCropableImageView(UIImage?)
    }
    
    enum Result {
        case requestShowLoading
        case canceLoading
        case didFinishLoading
        case dismissPhotoPicker
        case setThumbnail(UIImage)
        case requestCropImageForCropableImageView
        case videoThumbnailResult(UIImage?)
        case requestFinishCoverPicker
        case onError(ShopLiveCommonError)
    }
    
    private var videoUrl : URL?
    private var videoAsset : AVAsset?
    private var avPlayer : AVPlayer?
    private var currentSeekTime : CMTime = .zero
    private var imageGenerator : AVAssetImageGenerator?
    private var imageGeneratorQueue = DispatchQueue(label: "shopLiveImageGeneratorQueue",qos: .background)
    private var cropImageResultFromCropableImageView : UIImage?
    private var shopliveCoverPickerData : ShopLiveCoverPickerData?
    
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
    
    private func onSetVideoUrl(url : URL) {
        self.videoUrl = url
        videoAsset = AVURLAsset(url: url)// AVAsset(url: url)
        self.avPlayer = AVPlayer()
        self.avPlayer?.replaceCurrentItem(with: AVPlayerItem(asset: videoAsset!))
        self.imageGenerator = AVAssetImageGenerator(asset: videoAsset!)
        self.imageGenerator?.appliesPreferredTrackTransform = true
        self.imageGenerator?.maximumSize = CGSize(width: 720, height: 1280)
        self.imageGenerator?.apertureMode = .cleanAperture
    }
    
    private func onSeekTo(time : CMTime) {
        self.avPlayer?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        self.currentSeekTime = time
    }
    
    private func onRequestOnConfirm() {
        if self.currentMode == .video {
            let seconds = CMTimeGetSeconds(currentSeekTime)
            self.getExtractThumbnail(at: seconds) { [weak self] resultImage in
                self?.resultHandler?( .videoThumbnailResult(resultImage))
                guard let resultImage = resultImage else { return }
                if let _ = self?.shopliveCoverPickerData?.shortsId {
                    self?.callShortformThumbnailAPI(image: resultImage)
                }
                else {
                    self?.resultHandler?( .requestFinishCoverPicker )
                }
            }
        }
        else {
            resultHandler?( .requestCropImageForCropableImageView )
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
}
extension ShopLiveCoverPickerReactor : SLPhotosPickerViewControllerDelegate {
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
                case .success(let shortsModel):
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
}
