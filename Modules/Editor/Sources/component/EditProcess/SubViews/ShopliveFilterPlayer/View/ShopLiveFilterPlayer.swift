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
        case setUpFilterPlayer(_ fileName : String, _ videoUrl : URL, _ videoSize : CGSize, centerCrop : Bool,isCropMode : Bool, isCropAvailable : Bool )
        
        case seekTo(CMTime)
        case setPlayerEndBoundaryTime(CMTime)
        case tingleVideo
        case seekToTingleStartedTime
        
        
        case playVideo
        case pauseVideo
        
        case setPlayBtnisHidden(Bool)
        
        case updateCropViewOnRotation(_ videoSize : CGSize)
        case updateGLKViewOnRotation(_ videoSize : CGSize)
        //애니메이션을 위해서 있는 Action 선제적으로 계산하려고
        case updatePlayerViewHeight(CGFloat,_ videoSize : CGSize)
        case updatePlayerViewHeightToMain(_ videoSize : CGSize)
        case checkIfCropRectExceedsBounds
        
        case setFilterConfig(String)
        case setFilterIntensity(Float)
        
        case setFFmpegTextBox(ShopLiveFFmpegTextBox)
        
        case setThumbnailGLKView
        //이미 crop된 영상을 다시 크롭창으로 띄울때 사용
        case setInitialCropRect(CGRect)
        //동영상의 프레임이 다를때 비율을 사용해야 할때
        case setInitialCropRectByRatio(CGRect)
        case setSpeedRate(CGFloat)
        case hideCropView(Bool)
        case setCropIsAvailable(Bool)
        // 에디팅 시작할때의 크롭 영역을 기억하기 위해서 사용
        // xbtn 눌러서 돌아갈때 이 크기 값으로 되돌리기 위해서
        case saveStartCropRect
        case revertCropChange
    }
    
    enum Result {
        case didPlaytoEndTime
        case didTapPlayBtn
        
        case didUpdateCropRect(CGRect)
        case didUpdateCropViewRect(CGRect)
        
        case videoTimeUpdated(Double)
        case timeControlStatusUpdated(AVPlayer.TimeControlStatus)
    }
    
    var resultHandler: ((Result) -> ())?
    
    
    private var videoGlkView : GLKView = {
        let view = GLKView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    /**
     그냥 비디오만으로는 play를 하지 앟는 이상 필터가 적용되지 않아서
     정지상태에서 필터의 효과를 보여줄려고 있음
     */
    private var thumbnalGlkView : GLKView = {
        let view = GLKView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
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
    
    var layerCornerRadius : CGFloat {
        set {
            layer.cornerRadius = newValue
            videoGlkView.layer.cornerRadius = newValue
            thumbnalGlkView.layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    init(fileName : String, videoUrl : URL, videoSize : CGSize, centerCrop : Bool = false,isCropMode : Bool = true, isCropAvailable : Bool = true ) {
        super.init(frame: .zero)
        self.setLayout()
        bindReactor()
        reactor.action( .setIsCropMode(isCropMode) )
        reactor.action( .setIsCropAvailable(isCropAvailable) )
        reactor.action( .setIsCenterCrop(centerCrop) )
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
        self.addGestureRecognizer(tapGesture)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .setUpFilterPlayer(let filename, let videoUrl, let videoSize, let centerCrop, let isCropMode, let isCropAvailable):
            self.onSetupFilterPlayer(fileName: filename, videoUrl: videoUrl,videoSize: videoSize,centerCrop: centerCrop, isCropMode: isCropMode, isCropAvailable: isCropAvailable)
        case .setInitialCropRect(let rect):
            self.onSetInitialCropRect(rect: rect)
        case .setInitialCropRectByRatio(let ratioRect):
            self.onSetInitialCropRectByRatio(ratioRect: ratioRect)
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
        case .updatePlayerViewHeight(let height, let size):
            self.onUpdatePlayerViewHeight(height: height,size: size)
        case .updatePlayerViewHeightToMain(let videoSize):
            self.onUpdatePlayerViewHeightToMain(size: videoSize)
        case .checkIfCropRectExceedsBounds:
            self.onCheckIfCropRectExceedsBounds()
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
        case .setSpeedRate(let rate):
            self.onSetSpeedRate(rate: rate)
        case .hideCropView(let hide):
            self.onHideCropView(hide : hide)
        case .setCropIsAvailable(let isAvailable):
            self.onSetIsCropAvailable(isAvailable: isAvailable)
        case .saveStartCropRect:
            self.onSaveStartCropRect()
        case .revertCropChange:
            self.onRevertCropChange()
        }
    }
    
    private func onSetupFilterPlayer(fileName : String, videoUrl : URL, videoSize : CGSize, centerCrop : Bool, isCropMode : Bool,isCropAvailable : Bool) {
        reactor.action( .setIsCropMode(isCropMode) )
        reactor.action( .setIsCropAvailable(isCropAvailable) )
        reactor.action( .setIsCenterCrop(centerCrop) )
        reactor.action( .setFileName(fileName) )
        reactor.action( .setVideoUrl(videoUrl) )
        reactor.action( .setVideoSize(videoSize) )
        reactor.action( .setAVPlayer(videoPlayerDelegate.videoPlayer.avPlayer) )
        reactor.action( .setUpFilterPlayer )
        onSetFilterConfig(config : "")
    }
    
    private func onSetInitialCropRect(rect : CGRect) {
        cropView.setInitialCropRect(rect: rect)
    }
    
    private func onSetInitialCropRectByRatio(ratioRect : CGRect) {
        let glkViewSize = self.getGLKViewSize()
        var cropviewRect : CGRect = .zero
        cropviewRect.origin.x = glkViewSize.width * ratioRect.origin.x
        cropviewRect.origin.y = glkViewSize.height * ratioRect.origin.y
        cropviewRect.size.width = glkViewSize.width * ratioRect.width
        cropviewRect.size.height = glkViewSize.height * ratioRect.height
        cropView.setInitialCropRect(rect: cropviewRect)
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
    
    private func onUpdatePlayerViewHeight(height : CGFloat,size : CGSize) {
        let frameHeight = height
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
        videoPlayerDelegate.displayMode = ShopliveFilterSDKVideoPlayerViewDisplayModeAspectFill
        cropView.updateCropRectWithCustomSize(size: CGSize(width: glkViewWidthAnc.constant, height: glkViewHeightAnc.constant))
    }
    
    private func onUpdatePlayerViewHeightToMain(size : CGSize) {
        glkViewWidthAnc.constant = self.frame.width
        glkViewHeightAnc.constant = self.frame.height
        
        videoPlayerDelegate.displayMode = ShopliveFilterSDKVideoPlayerViewDisplayModeAspectFill
        cropView.updateCropRectWithCustomSize(size: CGSize(width: glkViewWidthAnc.constant, height: glkViewHeightAnc.constant))
    }
    
    private func onCheckIfCropRectExceedsBounds() {
        cropView.checkIfCropRectExceedsBounds()
    }
    
    private func onSetPlayBtnIsHidden(isHidden : Bool) {
        playButton.isHidden = isHidden
    }
    
    private func onUpdateGLKViewOnRotation(videoSize : CGSize) {
        self.redrawGLKView(size : videoSize, centerCrop: reactor.getIsCenterCrop())
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
    
    private func onSetSpeedRate(rate : CGFloat) {
        reactor.action( .setSpeedRate(rate) )
    }
    
    private func onHideCropView(hide : Bool) {
        self.cropView.isHidden = hide
    }
    
    private func onSetIsCropAvailable(isAvailable : Bool) {
        self.cropView.setIsCropAvailable(isAvailable: isAvailable)
    }
    
    private func onSaveStartCropRect() {
        let rect = cropView.getCropViewRect()
        reactor.action( .saveEditingStartCropRect(rect) )
    }
    
    private func onRevertCropChange() {
        cropView.setInitialCropRect(rect: reactor.getEditingStartCropRect() ?? cropView.frame)
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
                case .setGLKViewSize(let glkSize, let centerCrop, let isCropMode, let isCropAvailable):
                    self.onSetGLKViewSize(size: glkSize,centerCrop: centerCrop, isCropMode: isCropMode, isCropAvailable: isCropAvailable)
                case .setPlayBtnHidden(let isHidden):
                    self.playButton.isHidden = isHidden
                case .setThumbnailGLKHidden(let isHidden):
                    self.thumbnalGlkView.isHidden = isHidden
                case .setThumnailGLKimage(let image):
                   _ = self.thumbnailImageViewDelegate?.setUIImage(image)
                case .setThumbnailGLKFilterConfig(let filterConfig):
                    self.onSetThumbnailGLKFilterConfig(filterConfig: filterConfig)
                case .setCropViewHidden(let isHidden):
                    self.onSetCropViewHidden(isHidden: isHidden)
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
        reactor.action( .pauseVideo )
    }
    
    private func onSetGLKViewSize(size : CGSize, centerCrop : Bool,isCropMode : Bool, isCropAvailable : Bool) {
        self.redrawGLKView(size: size,centerCrop: centerCrop)
        guard isCropMode else { return }
        self.cropView.videoResolution = size
        self.cropView.updateCropArea()
        self.cropView.setIsCropAvailable(isAvailable: isCropAvailable)
        resultHandler?( .didUpdateCropRect(self.cropView.getCropRect()) )
        resultHandler?( .didUpdateCropViewRect(self.cropView.getCropViewRect()) )
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
    
    private func redrawGLKView(size : CGSize, centerCrop : Bool) {
        let frameHeight = self.frame.height
        let frameWidth = self.frame.width
        if centerCrop {
            glkViewWidthAnc.constant = frameWidth
            glkViewHeightAnc.constant = frameHeight
        }
        else {
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
        }
        videoPlayerDelegate.displayMode = ShopliveFilterSDKVideoPlayerViewDisplayModeAspectFill
        self.layoutIfNeeded()
    }
    
    private func onSetThumbnailGLKFilterConfig(filterConfig : String) {
        thumbnailImageViewDelegate?.setFilterWithConfig(filterConfig)
    }
    
    private func onSetCropViewHidden(isHidden : Bool) {
        self.cropView.isHidden = isHidden
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
    
    func getGLKViewSize() -> CGSize {
        return CGSize(width: glkViewWidthAnc.constant, height: glkViewHeightAnc.constant)
    }
}
extension ShopLiveFilterPlayer : SLVideoEditorPlayerCropViewDelegate {
    func updateCropRect(frame: CGRect) {
        guard reactor.getIsCropMode() else { return }
        resultHandler?( .didUpdateCropRect(frame) )
        resultHandler?( .didUpdateCropViewRect(cropView.getCropViewRect()) )
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
//            videoGlkView.widthAnchor.constraint(equalTo: self.widthAnchor),
//            videoGlkView.heightAnchor.constraint(equalTo: self.heightAnchor),
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
