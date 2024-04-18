//
//  ShopLiveFilterPlayer.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/14/23.
//

import Foundation
import UIKit
import ShopliveFilterSDK
import GLKit
import MobileCoreServices
import ShopliveSDKCommon
import MetalKit





class ShopLiveFilterPlayer : UIView, SLReactor {
    
    enum Action {
        case setUpFilterPlayer(_ fileName : String, _ videoUrl : URL, _ videoSize : CGSize )
        case seekTo(CMTime)
        case setPlayerEndBoundaryTime(CMTime)
        case tingleVideo
        case seekToTingleStartedTime
        
        case playVideo
        case pauseVideo
        
        case setPlayBtnisHidden(Bool)
        
        case updateCropViewOnRotation(_ videoSize : CGSize)
        case updateGLKViewOnRotation(_ videoSize : CGSize)
        
        case setFilterConfig(String)
        case setFilterIntensity(Float)
        
        case setFFmpegTextBox(ShopLiveFFmpegTextBox)
        
        case setThumbnailGLKView
    }
    
    enum Result {
        case didPlaytoEndTime
        case didTapPlayBtn
        
        case didUpdateCropRect(CGRect)
        case videoTimeUpdated(Double)
        case timeControlStatusUpdated(AVPlayer.TimeControlStatus)
    }
    
    var resultHandler: ((Result) -> ())?
    
    
    private var videoGlkView : GLKView = {
        let view = GLKView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var thumbnalGlkView : GLKView = {
        let view = GLKView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    lazy private var glkViewWidthAnc : NSLayoutConstraint = {
        return videoGlkView.widthAnchor.constraint(equalToConstant: 100)
    }()
    
    lazy private var glkViewHeightAnc : NSLayoutConstraint = {
        return videoGlkView.heightAnchor.constraint(equalToConstant: 100)
    }()
    
    private lazy var playButton: UIButton = {
        let view = UIButton(type: .custom)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setImage(ShopLiveShortformEditorSDKAsset.slEditorPlayButton.image, for: .normal)
        return view
    }()
    
    private lazy var cropView : SLVideoEditorPlayerCropView = {
        let view = SLVideoEditorPlayerCropView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        view.backgroundColor = .clear
        return view
    }()
    
    
    lazy private var videoPlayerDelegate : ShopliveFilterSDKVideoPlayerViewHandler = ShopliveFilterSDKVideoPlayerViewHandler(glkView: self.videoGlkView)
    lazy private var thumbnailImageViewDelegate = ShopliveFilterSDKImageViewHandler(glkView: self.thumbnalGlkView)
    
    private var videoFrameRecorder = ShopliveFilterSDKFrameRecorder()
    
    private let reactor = ShopLiveFilterPlayerReactor()
    
    init(fileName : String, videoUrl : URL, videoSize : CGSize) {
        super.init(frame: .zero)
        self.setLayout()
        bindReactor()
        reactor.action( .setFileName(fileName) )
        reactor.action( .setVideoUrl(videoUrl) )
        reactor.action( .setVideoSize(videoSize) )
        reactor.action( .setAVPlayer(videoPlayerDelegate.videoPlayer.avPlayer) )
        reactor.action( .setUpFilterPlayer )
        
        playButton.addTarget(self, action: #selector(playBtnTapped(sender: )), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCropView(sender: )))
        cropView.addGestureRecognizer(tapGesture)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setLayout()
        bindReactor()
        
        playButton.addTarget(self, action: #selector(playBtnTapped(sender: )), for: .touchUpInside)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapCropView(sender: )))
        cropView.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .setUpFilterPlayer(let filename, let videoUrl, let videoSize):
            self.onSetupFilterPlayer(fileName: filename, videoUrl: videoUrl,videoSize: videoSize)
        case .seekTo(let seekTime):
            self.onSeekTo(time: seekTime)
        case .tingleVideo:
            self.onTingleVideo()
        case .seekToTingleStartedTime:
            self.onSeekToTingleStartTime()
        case .setPlayerEndBoundaryTime(let boundaryTime):
            reactor.action( .setPlayerEndBoundaryTime(boundaryTime) )
        case .playVideo:
            self.onPlayVideo()
        case .pauseVideo:
            self.onPauseVideo()
        case .updateCropViewOnRotation(let videoSize):
            self.onUpdateCropViewOnRotation(videoSize: videoSize)
        case .setPlayBtnisHidden(let isHidden):
            self.onSetPlayBtnIsHidden(isHidden: isHidden)
        case .updateGLKViewOnRotation(let videoSize):
            self.onUpdateGLKViewOnRotation(videoSize: videoSize)
        case .setFilterConfig(let filter):
            self.onSetFilterConfig(config: filter)
        case .setFilterIntensity(let filterIntensity):
            self.onSetFilterIntensity(intensity: filterIntensity)
        case .setFFmpegTextBox(let textBox):
            self.onSetFFmpegTextBox(textBox: textBox)
        case .setThumbnailGLKView:
            self.onSetThumbnailGLKView()
        
        }
    }
    
    private func onSetupFilterPlayer(fileName : String, videoUrl : URL, videoSize : CGSize) {
        reactor.action( .setFileName(fileName) )
        reactor.action( .setVideoUrl(videoUrl) )
        reactor.action( .setVideoSize(videoSize) )
        reactor.action( .setAVPlayer(videoPlayerDelegate.videoPlayer.avPlayer) )
        reactor.action( .setUpFilterPlayer )
        onSetFilterConfig(config : "")
    }
    
    private func onSeekTo(time : CMTime) {
        if thumbnalGlkView.isHidden == false {
            thumbnalGlkView.isHidden = true
        }
        reactor.action( .seekTo(time) )
    }
    
    private func onTingleVideo() {
        reactor.action( .tingleVideo )
    }
    
    private func onSeekToTingleStartTime() {
        reactor.action( .seekToTingleStartTime )
    }
    
    private func onPlayVideo() {
        reactor.action( .playVideo )
    }
    
    private func onPauseVideo() {
        reactor.action( .pauseVideo )
    }
    
    private func onUpdateCropViewOnRotation(videoSize : CGSize) {
        self.cropView.videoResolution = videoSize
        self.cropView.updateCropArea()
        resultHandler?( .didUpdateCropRect(self.cropView.getCropRect()) )
        self.layoutIfNeeded()
    }
    
    private func onSetPlayBtnIsHidden(isHidden : Bool) {
        playButton.isHidden = isHidden
    }
    
    private func onUpdateGLKViewOnRotation(videoSize : CGSize) {
        self.redrawGLKView(size : videoSize)
    }
    
    private func onSetFilterConfig(config : String) {
        videoPlayerDelegate.setFilterWithConfig(config)
        thumbnailImageViewDelegate?.setFilterWithConfig(config)
        reactor.action( .setFilterConfig(config) )
    }
    
    private func onSetFilterIntensity(intensity : Float) {
        videoPlayerDelegate.setFilterIntensity(intensity)
        thumbnailImageViewDelegate?.setFilterIntensity(intensity)
        reactor.action( .setFilterIntensity(intensity) )
    }
    
    private func onSetFFmpegTextBox(textBox : ShopLiveFFmpegTextBox) {
        self.addSubview(textBox)
        let textFrame =  NSString(string: textBox.getText()).size(withAttributes: [.font : UIFont.systemFont(ofSize: CGFloat(textBox.getTextFontSize()), weight: .regular)])
        
        let originX = videoGlkView.center.x - (textFrame.width / 2)
        let originY = playButton.frame.maxY + 10
        textBox.frame = CGRect(origin: .init(x: originX, y: originY), size: .init(width: textFrame.width, height: CGFloat(textBox.getTextFontSize() + 2)))
        
        textBox.setCoordinateSuperFrame(frame: .init(x: 0, y: 0, width: ceil(glkViewWidthAnc.constant), height: ceil(glkViewHeightAnc.constant)))
        textBox.setCoordinateSuperView(superView: videoGlkView)
        reactor.action( .setFFmpegTextBox(textBox) )
    }
    
    private func onSetThumbnailGLKView() {
        thumbnalGlkView.isHidden = false
        let isReversedTargetSize = videoPlayerDelegate.videoPlayer.reverseTargetSize
        reactor.action( .setIsFilterSDKCurrentItemVideoSizeIsReversed(isReversedTargetSize) )
        reactor.action( .onSetThumbnailGLKView )
    }
    
}
//MARK: - UI actions
extension ShopLiveFilterPlayer {
    @objc func playBtnTapped(sender : UIButton) {
        resultHandler?( .didTapPlayBtn )
    }
    
    @objc func didTapCropView(sender : UITapGestureRecognizer) {
        resultHandler?( .didTapPlayBtn )
    }
}
//MARK: - reactor functions
extension ShopLiveFilterPlayer {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .setVideoUrlToPlayer( _):
                break
            case .didPlayToEndTime:
                self.onDidPlayToEndTime()
            case .videoTimeUpdated(let time):
                self.onVideoTimeUpdated(time: time)
            case .timeControlStatusTimeUpdated(let status):
                self.onTimeControlStatusUpadated(timeControlStatus: status)
            default:
                break
            }
        }
        
        reactor.mainQueueResultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .setVideoUrlToPlayer(let videoUrl):
                    self.setVideoUrlToPlayer(videoUrl: videoUrl)
                case .setGLKViewSize(let glkSize):
                    self.onSetGLKViewSize(size: glkSize)
                case .setPlayBtnHidden(let isHidden):
                    self.playButton.isHidden = isHidden
                case .setThumbnailGLKHidden(let isHidden):
                    self.thumbnalGlkView.isHidden = isHidden
                case .setThumnailGLKimage(let image):
                   _ = self.thumbnailImageViewDelegate?.setUIImage(image)
                case .setThumbnailGLKFilterConfig(let filterConfig):
                    self.onSetThumbnailGLKFilterConfig(filterConfig: filterConfig)
                default:
                    break
                }
            }
        }
    }
    
    private func setVideoUrlToPlayer(videoUrl : URL) {
        videoPlayerDelegate.start(with: videoUrl) { [weak self] error in
            self?.reactor.action( .setVideoOutput )
            guard let error = error else { return }
            ShopLiveLogger.debugLog("[ShopliveShortformVideoEditor] error playing filterplayerview error \(error)")
        }
        videoPlayerDelegate.pause()
    }
    
    private func onSetGLKViewSize(size : CGSize) {
        self.redrawGLKView(size: size)
        self.cropView.videoResolution = size
        self.cropView.updateCropArea()
        resultHandler?( .didUpdateCropRect(self.cropView.getCropRect()) )
    }
    
    private func onDidPlayToEndTime() {
        resultHandler?( .didPlaytoEndTime )
    }
    
    private func onVideoTimeUpdated(time : Double) {
        resultHandler?( .videoTimeUpdated(time) )
    }
    
    private func onTimeControlStatusUpadated(timeControlStatus : AVPlayer.TimeControlStatus) {
        resultHandler?( .timeControlStatusUpdated(timeControlStatus) )
    }
    
    private func redrawGLKView(size : CGSize) {
        let frameHeight = self.frame.height
        
        if size.width < size.height {
            glkViewWidthAnc.constant = frameHeight * (size.width / size.height)
            glkViewHeightAnc.constant = frameHeight
        }
        else {
            if UIScreen.isLandscape_SL {
                glkViewWidthAnc.constant = frameHeight * (size.width / size.height)
                glkViewHeightAnc.constant = frameHeight
            }
            else {
                glkViewWidthAnc.constant = self.frame.width
                glkViewHeightAnc.constant = self.frame.width * (size.height / size.width)
            }
        }
        self.layoutIfNeeded()
    }
    
    private func onSetThumbnailGLKFilterConfig(filterConfig : String) {
        thumbnailImageViewDelegate?.setFilterWithConfig(filterConfig)
    }
    
}
//MARK: -Getter
extension ShopLiveFilterPlayer {
    func getFilterConfig() -> String? {
        return reactor.getFilterConfig()
    }
    
    func getFilterIntensity() -> Float {
        return reactor.getFilterIntensity()
    }
}
extension ShopLiveFilterPlayer : SLVideoEditorPlayerCropViewDelegate {
    func updateCropRect(frame: CGRect) {
        resultHandler?( .didUpdateCropRect(frame) )
    }
}
extension ShopLiveFilterPlayer {
    private func setLayout() {
        self.addSubview(videoGlkView)
        self.addSubview(thumbnalGlkView)
        self.addSubview(playButton)
        self.addSubview(cropView)
        
        
        NSLayoutConstraint.activate([
            videoGlkView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            videoGlkView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            glkViewWidthAnc,
            glkViewHeightAnc,
            
            thumbnalGlkView.topAnchor.constraint(equalTo: videoGlkView.topAnchor),
            thumbnalGlkView.leadingAnchor.constraint(equalTo: videoGlkView.leadingAnchor),
            thumbnalGlkView.trailingAnchor.constraint(equalTo: videoGlkView.trailingAnchor),
            thumbnalGlkView.bottomAnchor.constraint(equalTo: videoGlkView.bottomAnchor),
            
            cropView.topAnchor.constraint(equalTo: videoGlkView.topAnchor),
            cropView.leadingAnchor.constraint(equalTo: videoGlkView.leadingAnchor),
            cropView.trailingAnchor.constraint(equalTo: videoGlkView.trailingAnchor),
            cropView.bottomAnchor.constraint(equalTo: videoGlkView.bottomAnchor),
            
            playButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            playButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            playButton.widthAnchor.constraint(equalToConstant: 72),
            playButton.heightAnchor.constraint(equalToConstant: 72)
        ])
    }
}
