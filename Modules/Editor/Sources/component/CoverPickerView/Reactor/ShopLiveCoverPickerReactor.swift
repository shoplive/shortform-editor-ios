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
        
        case setVideoUrl(URL)
        case requestOnConfirm
        case setCurrentMode(Mode)
    }
    
    enum Result {
        case canceLoading
        case didFinishLoading
        case dismissPhotoPicker
        case setThumbnail(UIImage)
        case requestCropImageForCropableImageView
    }
    
    private var videoUrl : URL?
    private var videoAsset : AVAsset?
    private var avPlayer : AVPlayer?
    private var imageGenerator : AVAssetImageGenerator?
    private var imageGeneratorQueue = DispatchQueue(label: "shopLiveImageGeneratorQueue",qos: .background)
    
    
    private weak var shortformEditorDelegate : ShopLiveShortformEditorDelegate?
    private weak var videoEditorDelegate : ShopLiveVideoEditorDelegate?
    private var isViewAppeared : Bool = false
    private var blockInitialCropInViewDidLayoutSubView : Bool = false
    private var glkViewSize : CGSize = .zero
    private var currentMode : Mode = .video
    
    var resultHandler: ((Result) -> ())?
   
    override init() {
        super.init()
    }
    
    deinit {
        ShopLiveLogger.tempLog("ShopLiveCoverPickerReactor deinit")
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewDidLoad:
            self.onViewDidLoad()
        case .viewDidAppear:
            self.onViewDidAppear()
        case .viewDidLayoutSubView:
            self.onViewDidLayoutSubView()
        case .setVideoUrl(let videoUrl):
            self.onSetVideoUrl(url: videoUrl)
        case .seekTo(let time):
            self.onSeekTo(time: time)
        case .requestOnConfirm:
            self.onRequestOnConfirm()
        case .setCurrentMode(let mode):
            self.onSetCurrentMode(mode: mode)
            
        }
    }
    
    private func onViewDidLoad() {
        
    }
    
    private func onViewDidAppear() {
        
    }
    
    private func onViewDidLayoutSubView() {
        
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
    }
    
    private func onRequestOnConfirm() {
        if self.currentMode == .video {
            
        }
        else {
            resultHandler?( .requestCropImageForCropableImageView )
        }
    }
    
    private func onSetCurrentMode(mode : Mode) {
        self.currentMode = mode
    }
}
extension ShopLiveCoverPickerReactor {
    private func getExtractThumbnail(at targetSec : Double, completion : @escaping(UIImage?) -> ()) {
        guard let imageGenerator = imageGenerator else {
            completion(nil)
            return
        }
        imageGeneratorQueue.sync { [weak self] in
            guard let self = self else { return }
            let time = CMTime(seconds: targetSec, preferredTimescale: 44100)
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                completion(UIImage.init(cgImage: cgImage))
            }
            catch(let error){
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
        resultHandler?( .didFinishLoading )
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
