//
//  ShopLiveFilterPlayerReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/15/23.
//

import Foundation
import UIKit
import ShopliveFilterSDK
import ShopliveSDKCommon
import Photos
import AssetsLibrary
import VideoToolbox


class ShopLiveFilterPlayerReactor : NSObject, SLReactor {
    enum Action {
        case setUpFilterPlayer
        case setFileName(String)
        case setVideoUrl(URL)
        case setVideoSize(CGSize)
        case setAVPlayer(AVPlayer)
        
        case seekTo(CMTime)
        case tingleVideo
        case seekToTingleStartTime
        case setPlayerEndBoundaryTime(CMTime)
        
        case playVideo
        case pauseVideo
        case setFilterConfig(String)
        case setFilterIntensity(Float)
        
        case setFFmpegTextBox(ShopLiveFFmpegTextBox)
        
        case setVideoOutput
        case onSetThumbnailGLKView
        case setIsFilterSDKCurrentItemVideoSizeIsReversed(Bool)
    }
    
    enum Result {
        case setVideoUrlToPlayer(URL)
        case setGLKViewSize(CGSize)
        
        case setPlayBtnHidden(Bool)
        case didPlayToEndTime
        case videoTimeUpdated(Double)
        case timeControlStatusTimeUpdated(AVPlayer.TimeControlStatus)
        
        case setThumbnailGLKHidden(Bool)
        case setThumnailGLKimage(UIImage)
        case setThumbnailGLKFilterConfig(String)
    }
    
    private var avPlayer : AVPlayer?
    private var playStartTime : CMTime? = .zero
    private var videoSize : CGSize = .zero
    private var fileName : String = ""
    private var videoUrl : URL?
    private var boundaryTimeObserver : Any?
    private var playTimeObserver : Any?
    private var filterConfig : String?
    private var filterIntensity : Float = 1
    private var filterIntensitySeekAjdust : Double = 0.05
    private var videoOutput: AVPlayerItemVideoOutput?
    private var isFilterSDKCurrentItemVideoSizeIsReversed : Bool = false
    //필터 적용할때 영상위에 스샷올려놓고 그 아래에서는 영상이 게속 앞뒤 시간대로 게속 진동하면서 필터를 적용하는 로직으로 되어 있음
    private var isTingled : Bool = false
    private var tingleStartedTime : CMTime = .zero
    
    var resultHandler: ((Result) -> ())?
    var mainQueueResultHandler : ((Result) -> ())?
    
    override init() {
        super.init()
        let properties:[String: Any] = [
            (kVTCompressionPropertyKey_RealTime as String): kCFBooleanTrue ?? true,
                    (kVTCompressionPropertyKey_ProfileLevel as String): kVTProfileLevel_H264_High_AutoLevel,
                    (kVTCompressionPropertyKey_AllowFrameReordering as String): true,
                    (kVTCompressionPropertyKey_H264EntropyMode as String): kVTH264EntropyMode_CABAC,
                    (kVTCompressionPropertyKey_PixelTransferProperties as String): [
                        (kVTPixelTransferPropertyKey_ScalingMode as String): kVTScalingMode_Trim
                    ]
                ]

        
        self.videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: properties)
    }
    
    func action(_ action: Action) {

        switch action {
        case .setUpFilterPlayer:
            self.onSetUpFilterPlayer()
        case .setVideoOutput:
            self.onSetVideoOutPut()
        case .setFileName(let fileName):
            self.fileName = fileName
        case .setVideoUrl(let videoUrl):
            self.videoUrl = videoUrl
        case .setVideoSize(let videoSize):
            self.videoSize = videoSize
        case .setAVPlayer(let player):
            self.avPlayer = player
        case .seekTo(let time):
            self.onSeekTo(time: time)
        case .tingleVideo:
            self.onTingleVideo()
        case .seekToTingleStartTime:
            self.onSeekToTingleStartedTime()
        case .setPlayerEndBoundaryTime(let time):
            self.onSetPlayerEndBoundaryTimer(time: time)
        case .playVideo:
            self.onPlayVideo()
        case .pauseVideo:
            self.onPauseVideo()
        case .setFilterConfig(let filterConfig):
            self.onSetFilterConfig(config: filterConfig)
        case .setFilterIntensity(let intensity):
            self.onSetFilterIntensity(intensity: intensity)
        case .setFFmpegTextBox(let textBox):
            self.onSetFFmpegTextBox(textBox: textBox)
        case .onSetThumbnailGLKView:
            self.onSetThumbnailGLKView()
        case .setIsFilterSDKCurrentItemVideoSizeIsReversed(let isRotated):
            self.onSetIsFilterSDKCurrentItemVideoSizeIsReversed(isRotated: isRotated)
        }
    }
    
    
    private func onSetUpFilterPlayer() {
        if let url = videoUrl {
            mainQueueResultHandler?( .setVideoUrlToPlayer(url))
        }
        
        if self.videoSize != .zero {
            mainQueueResultHandler? ( .setGLKViewSize(self.videoSize) )
        }
        
        setUpPlayTimeObserver()
        setUpPlayerObserver()
    }
    
    private func onSetVideoOutPut() {
        if let videoOutput = self.videoOutput, let currentItem = self.avPlayer?.currentItem {
            if currentItem.outputs.contains(videoOutput) == false {
                currentItem.add(videoOutput)
            }
        }
    }
    
    private func setUpPlayTimeObserver() {
        self.removePlayTimeObserver()
        let time = CMTime(seconds: 0.01 , preferredTimescale: 44100)
        playTimeObserver = avPlayer?.addPeriodicTimeObserver(forInterval: time, queue: nil, using: { [weak self] time  in
            guard let self = self else { return }
            if let playTime = avPlayer?.currentItem?.currentTime() {
                self.resultHandler?( .videoTimeUpdated(playTime.seconds))
            }
        })
    }
    
    private func removePlayTimeObserver() {
        if let playTimeObserver = self.playTimeObserver {
            avPlayer?.removeTimeObserver(playTimeObserver)
            self.playTimeObserver = nil
        }
    }
    
    private func onSeekTo(time : CMTime) {
        avPlayer?.pause()
        avPlayer?.seek(to: time, toleranceBefore: .init(seconds: 1, preferredTimescale: 44100), toleranceAfter: .init(seconds: 1, preferredTimescale: 44100))
    }
    
    //TODO: - 개선점 앞단에서 throttling을 걸어서 너무 비번하게 시킹을 하지 않도록 해야함
    private func onTingleVideo() {
        if isTingled == false {
            isTingled = true
            guard let currentTime = avPlayer?.currentTime() else { return }
            tingleStartedTime = currentTime
        }
        else {
            guard let currentTime = avPlayer?.currentTime() else { return }
            if currentTime.seconds < tingleStartedTime.seconds {
                avPlayer?.seek(to: tingleStartedTime, toleranceBefore: .zero, toleranceAfter: .zero)
            }
            else {
                var targetTime : CMTime
                if tingleStartedTime.seconds > 1 {
                    targetTime = CMTime(seconds: tingleStartedTime.seconds - 1, preferredTimescale: tingleStartedTime.timescale)
                }
                else if tingleStartedTime.seconds < (avPlayer?.currentItem?.duration ?? .zero).seconds - 1 {
                    targetTime = CMTime(seconds: tingleStartedTime.seconds + 1, preferredTimescale: tingleStartedTime.timescale)
                }
                else {
                    targetTime = tingleStartedTime
                }
                avPlayer?.seek(to: targetTime, toleranceBefore: .zero, toleranceAfter: .zero)
            }
        }
    }
    
    private func onSeekToTingleStartedTime() {
        self.avPlayer?.seek(to: tingleStartedTime, toleranceBefore: .zero, toleranceAfter: .zero)
        tingleStartedTime = .zero
    }
    
    private func onSetPlayerEndBoundaryTimer(time : CMTime) {
        self.avPlayer?.pause()
        mainQueueResultHandler?( .setPlayBtnHidden(false) )
        self.removePlayerBoundaryEndTimer()
        boundaryTimeObserver = avPlayer?.addBoundaryTimeObserver(forTimes: [NSValue(time:time)], queue: nil, using: { [weak self] in
            guard let self = self else { return }
            self.avPlayer?.pause()
            self.resultHandler?( .didPlayToEndTime )
        })
    }
    
    private func removePlayerBoundaryEndTimer() {
        if let boundaryTimeObserver = self.boundaryTimeObserver {
            avPlayer?.removeTimeObserver(boundaryTimeObserver)
            self.boundaryTimeObserver = nil
        }
    }
    
    private func onPlayVideo() {
        mainQueueResultHandler?( .setPlayBtnHidden(true) )
        mainQueueResultHandler?( .setThumbnailGLKHidden(true) )
        avPlayer?.play()
    }
    
    private func onPauseVideo() {
        mainQueueResultHandler?( .setPlayBtnHidden(false) )
        avPlayer?.pause()
    }
    
    private func onSetFilterConfig(config : String?) {
        self.filterConfig = config
    }
    
    private func onSetFilterIntensity(intensity : Float) {
        self.filterIntensity = intensity
    }
    
    private func onSetFFmpegTextBox(textBox : ShopLiveFFmpegTextBox){
        textBox.setVideoResolution(resolution: self.videoSize)
    }
    
    private func onSetThumbnailGLKView() {
        guard avPlayer?.timeControlStatus == .paused else { return }
        mainQueueResultHandler?( .setThumbnailGLKHidden(false) )
        setThumnailSnapShot()
        if let filterConfig = self.filterConfig {
            mainQueueResultHandler?( .setThumbnailGLKFilterConfig(filterConfig) )
        }
    }
    
    private func onSetIsFilterSDKCurrentItemVideoSizeIsReversed(isRotated : Bool) {
        isFilterSDKCurrentItemVideoSizeIsReversed = isRotated
    }
}
//MARK: -getter
extension ShopLiveFilterPlayerReactor {
    func getFilterConfig() -> String? {
        return self.filterConfig
    }
    
    func getFilterIntensity() -> Float {
        return self.filterIntensity
    }
}
//MARK: -observer
extension ShopLiveFilterPlayerReactor {
    private func setUpPlayerObserver() {
        removePlayerObserver()
        guard let player = self.avPlayer else { return }
        player.addObserver(self, forKeyPath: "timeControlStatus", options: .new, context: nil)
        
    }
    
    private func removePlayerObserver() {
        self.avPlayer?.safeRemoveObserver_SL(self, forKeyPath: "timeControlStatus")
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath,
                keyPath == "timeControlStatus",
              let _ = change?[.newKey] else { return }
        guard let newValue: Int = change?[.newKey] as? Int else { return }
        guard let newStatus = AVPlayer.TimeControlStatus(rawValue: newValue) else { return }
        resultHandler?( .timeControlStatusTimeUpdated(newStatus) )
    }
}
//MARK: -snapshot
extension ShopLiveFilterPlayerReactor {
    private func setThumnailSnapShot() {
        guard let videoOutput = self.videoOutput,
              let currentItem = self.avPlayer?.currentItem,
              let track = currentItem.asset.tracks.first else { return }
        
        let preferredTransform = track.preferredTransform
        
        let rotation = atan2(preferredTransform.b, preferredTransform.a)
        
        let currentTime = currentItem.currentTime()
        if let buffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) {
            let ciImage : CIImage = CIImage(cvPixelBuffer: buffer)
            let imgRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(buffer), height: CVPixelBufferGetHeight(buffer))
            if let videoImage = CIContext().createCGImage(ciImage, from: imgRect) {
                var image = UIImage.init(cgImage: videoImage)
                
                if rotation != 0, let rotatedImage = rotateUIImageToPortrait(image: image) {
                    image = rotatedImage
                }
                
                mainQueueResultHandler?( .setThumnailGLKimage(image) )
            }
        }
    }
    
    
    private func rotateUIImageToPortrait(image : UIImage) -> UIImage? {
        var transform: CGAffineTransform = CGAffineTransform.identity
        transform = transform.translatedBy(x: 0, y: image.size.height);
        //TODO: -  트랜스폼 각도를 오리엔테이션마다 다르게 해줘야 하나?,(현재는 오른쪽으로 회전되어있다고 가정하고 코드 작성, rotation = 1.5xxxx)
        transform = transform.rotated(by: CGFloat(-Double.pi / 2.0));
        let ctx: CGContext = CGContext(data: nil,
                                       width: Int(image.size.width),
                                       height: Int(image.size.height),
                                       bitsPerComponent: image.cgImage!.bitsPerComponent,
                                       bytesPerRow: 0,
                                       space: image.cgImage!.colorSpace!,
                                       bitmapInfo: image.cgImage!.bitmapInfo.rawValue)!;
        ctx.concatenate(transform)
        ctx.draw(image.cgImage!, in: CGRect(x: 0,y: 0,width: image.size.height,height: image.size.width))
        if let image = ctx.makeImage() {
            return UIImage(cgImage: image)
        }
        return nil
    }
}
