 //
//  SLVideoEditorSliderView.swift
//  matrix-shortform-ios
//
//  Created by 김우현 on 4/20/23.
//

import Foundation
import UIKit
import AVKit

enum VideoEditorItemPosition {
    case left
    case middle
    case right
    
    var type: String {
        switch self {
        case .left:
            return "left"
        case .right:
            return "right"
        case .middle:
            return "middle"
        }
    }
}

protocol SLVideoEditorSliderViewDelegate: AnyObject {
    func seekTo(time: CMTime, handleType: SLVideoEditorSliderHandleType)
    func updateCropTime(start: CMTime, end: CMTime)
}

class SLVideoEditorSliderView: UIView {
    typealias globalConfig = ShopLiveEditorConfigurationManager
    
    weak var delegate: SLVideoEditorSliderViewDelegate?
    
    private var cropTime: (start: CMTime, end: CMTime) = (.zero, .zero)
    
    private(set) var videoRatio: CGSize = CGSize(width: 9, height: 16)
    private(set) var videoUrl: URL?
    private var videoDuration: CGFloat = 0
    private var videoTimeScale: CMTimeScale = 600
    
    private var barWidth: CGFloat = 0
    private var barWidthEdge: CGFloat = .zero
    private var barHeight: CGFloat = 60
    private var frameTotalSizeWidth: CGFloat {
        guard self.videoDuration >= 60 else {
            return self.videoFramesView.contentSize.width
        }
        return (self.barWidth / 60) * self.videoDuration
    }
    
    private var imageGenerator: AVAssetImageGenerator!
    
    private var widthPerFrame: CGFloat = 0
    private var numberOfFramesOnScreen: Int = 0
    private var timeForPerFrame: CGFloat = 0
    private var totalFrame: Int = 0
    private var minTrimTime : CGFloat {
        return globalConfig.shared.videoTrimOption.minVideoDuration
    }
    private var maxTrimTime : CGFloat  {
        return globalConfig.shared.videoTrimOption.maxVideoDuration
    }
    
    
    private var timeGapInitialized: Bool = false
    
    private var leftHandleOffset: CGFloat = 0
    private lazy var rightHandleOffset: CGFloat = 0
    
    private lazy var videoFramesView: SLVideoEditorScrollView = {
        let view = SLVideoEditorScrollView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    private lazy var handleView: SLVideoEditorSliderHandleView = {
        let view = SLVideoEditorSliderHandleView(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    init(videoUrl: URL?) {
        self.videoUrl = videoUrl
        super.init(frame: .zero)
        
        layout()
        attributes()
        bindView()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard needResetSliderView else { return }
        
        needResetSliderView = false
        DispatchQueue.main.async {
            self.videoFramesView.removeAllItems()

            self.safeWidth = self.safeAreaLayoutGuide.layoutFrame.size.width
            
            self.leftHandleOffset = 0//((Int(self.safeWidth) % 2) == 0 ? 55 : 56)
            
            DispatchQueue.global().async { [weak self] in
                guard let self = self else { return }
                if let videoUrl = self.videoUrl {
                    let asset = AVAsset.init(url: videoUrl)
                    self.videoDuration = CGFloat(CMTimeGetSeconds(asset.duration))
                    self.handleView.timeGapSpacing = self.videoDuration < 60 ? 1 : 0
                    self.rightHandleOffset = self.safeWidth - 56 - self.handleView.timeGapSpacing
                    self.barWidth = self.safeWidth - 56
                    self.videoTimeScale = asset.duration.timescale
                    
                    self.barWidthEdge = (Int(self.safeWidth) % 2) == 0 ? 0 : 1
                    
                    self.widthPerFrame = (self.videoRatio.width / self.videoRatio.height) * self.barHeight
                    
                    let frameInScreen: Int = Int(round(self.barWidth / self.widthPerFrame)) // 한프레임안에 몇개 있냐??
                    
                    self.numberOfFramesOnScreen = frameInScreen % 2 != 0 ? frameInScreen + 1 : frameInScreen
                    
                    self.widthPerFrame = self.barWidth / CGFloat(self.numberOfFramesOnScreen)
                    
                    if self.videoDuration >= 60 {
                        self.timeForPerFrame =  self.widthPerFrame / (self.barWidth / maxTrimTime)
                    }
                    else {
                        self.timeForPerFrame = self.widthPerFrame / (self.barWidth / self.videoDuration)
                    }
                    
                    let restPieceValue = self.videoDuration.truncatingRemainder(dividingBy: timeForPerFrame)
                    
                    let needAdditionPiece: Bool = self.videoDuration < 60 ? false : restPieceValue < timeForPerFrame
                    
                    let restPieceWidth = (widthPerFrame / timeForPerFrame) * restPieceValue
                    
                    self.imageGenerator = AVAssetImageGenerator.init(asset: asset)
                    self.imageGenerator?.appliesPreferredTrackTransform = true
                    
                    self.imageGenerator?.maximumSize = CGSize(width: 720, height: 1280)
                    self.imageGenerator?.apertureMode = .cleanAperture
                    self.totalFrame = Int(self.videoDuration / self.timeForPerFrame)
                    
                    if ((CGFloat(self.totalFrame) * self.widthPerFrame) < self.barWidth) || needAdditionPiece {
                        self.totalFrame += 1
                    }

                    DispatchQueue.main.async {
                        self.videoFramesView.setItemInset(UIEdgeInsets(top: 0, left: (28 - self.barWidthEdge), bottom: 0, right: 28))
                        self.videoFramesView.setItemSize(CGSize(width: self.widthPerFrame, height: 60))
                    }
                    
                    var i = 0
                    var time: CGFloat = 0.0
                    
                    while i < self.totalFrame {
                        
                        let image = self.imageFromVideo(at: time)
                        
                        time += self.timeForPerFrame
                        i+=1
                        
                        DispatchQueue.main.async { [weak self] in
                            guard let self = self else { return }
                            if i == self.totalFrame {
                                needAdditionPiece ? self.videoFramesView.addItem(image, newSize: CGSize(width: restPieceWidth, height: 60)) : self.videoFramesView.addItem(image)
                            } else {
                                self.videoFramesView.addItem(image)
                            }
                            
                            self.videoFramesView.updateMaskDim(CGRect(x: self.leftHandleOffset, y: 0, width: self.rightHandleOffset - self.leftHandleOffset, height: 60))
                            
                            if i == self.totalFrame {
                                let standardGapEdge : CGFloat
                                if self.videoDuration >= 60 {
                                    standardGapEdge = (self.barWidth / 60)
                                }
                                else if ((((self.barWidth / self.videoDuration)) / self.frameTotalSizeWidth) * self.videoDuration) < 1.0 {
                                    standardGapEdge = 1
                                }
                                else {
                                    standardGapEdge = 0
                                }
                                
                                self.handleView.betweenHandleGap = self.videoDuration >= 60 ? ((self.barWidth + standardGapEdge) / 60) : ((self.barWidth + standardGapEdge) / self.videoDuration)
                                self.handleView.timebarLoaded = true
                                self.initTimeGap()
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func layout() {
        self.backgroundColor = .black
        
        self.addSubview(videoFramesView)
        videoFramesView.fit_SL()
        
        self.addSubview(handleView)
        let handleViewConstraint = [
            handleView.leftAnchor.constraint(equalTo: self.leftAnchor),
            handleView.rightAnchor.constraint(equalTo: self.rightAnchor),
            handleView.topAnchor.constraint(equalTo: self.topAnchor),
            handleView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ]
        NSLayoutConstraint.activate(handleViewConstraint)
        self.bringSubviewToFront(handleView)
    }
    
    private func attributes() {
        
    }
    
    private func bindView() {
        
    }

    private var safeWidth: CGFloat = 0
    
    private var needResetSliderView: Bool = true
    
    func onOrientationChange() {
        self.needResetSliderView = true
        handleView.onOrientationChange()
        self.layoutIfNeeded()
    }
    
    private func imageFromVideo(at: CGFloat) -> UIImage {
        do {
            let ct = CMTime(seconds: at, preferredTimescale: 44100)
            let ref = try imageGenerator.copyCGImage(at: ct, actualTime: nil)
            let image = UIImage.init(cgImage: ref)
            return image
        } catch let e {
            // print(e.localizedDescription)
        }
        return UIImage.init()
    }
    
}

extension SLVideoEditorSliderView: SLVideoEditorSliderHandleDelegate {
    func updateCurrentHandlePosition(changed: CGFloat, handleType: SLVideoEditorSliderHandleType) {
        
    }
    
    func updatedCurrentHandlePosition(view: UIView, handleType: SLVideoEditorSliderHandleType) {
        
    }
    
    func updatedCurrentHandlePosition(offset: CGFloat, handleType: SLVideoEditorSliderHandleType) {
        
        switch handleType {
        case .left:
            leftHandleOffset = offset - 28
            updateLeftHandleSeek()
            break
        case .right:
            rightHandleOffset = offset - 28
            updateRightHandleSeek()
            break
        }
         
        self.videoFramesView.updateMaskDim(CGRect(x: self.leftHandleOffset, y: 0, width: self.rightHandleOffset - self.leftHandleOffset, height: 60))
    }
    
    func getVideoTime(handleType: SLVideoEditorSliderHandleType) -> CMTime {
        let leftPosition = (self.videoFramesView.contentOffset.x + (28 - self.barWidthEdge) + leftHandleOffset)
        let rightPosition = (self.videoFramesView.contentOffset.x + (28 - self.barWidthEdge) + rightHandleOffset)
        let leftPostionPercent = leftPosition / self.frameTotalSizeWidth
        let rightPostionPercent = rightPosition / self.frameTotalSizeWidth
        
        let startTime = leftPostionPercent * self.videoDuration
        let endTime = rightPostionPercent * self.videoDuration
        switch handleType {
        case .left:
            return CMTime(seconds: startTime, preferredTimescale: 44100)
        case .right:
            return CMTime(seconds: endTime, preferredTimescale: 44100)
        }
    }
    
    private func updateTimeGap(from: String) {
        handleView.updateTimeGap(start: cropTime.start, end: cropTime.end)
    }
    
    private func initTimeGap() {
        if !updateCropTimeWhenValidate(from: "initTimeGap")  {
            cropTime = (.zero, CMTime(seconds: videoDuration >= 60 ? 60 : videoDuration, preferredTimescale: 44100))
        }
        
        delegate?.updateCropTime(start: cropTime.start, end: cropTime.end)
        updateTimeGap(from: "initTimeGap")
//        delegate?.sliderInitialize()
        self.timeGapInitialized = true
    }
    
    private func setTimeGap(from: String) {
        guard timeGapInitialized else {
            return
        }
        updateTimeGap(from: from)
    }
    
    func updateCropTime(from: String) {
        guard updateCropTimeWhenValidate(from: from) else { return }
        setTimeGap(from: from)
        delegate?.updateCropTime(start: cropTime.start, end: cropTime.end)
    }
    
    private func updateCropTimeWhenValidate(from: String) -> Bool {
        let left = getVideoTime(handleType: .left)
        let right = getVideoTime(handleType: .right)
        
        guard !left.seconds.isNaN && !left.seconds.isInfinite else {
            return false
        }
        guard !right.seconds.isNaN && !right.seconds.isInfinite else {
            return false
        }
        
        cropTime = (left, right)
        return true
    }
    
    func updateLeftHandleSeek() {
        guard updateCropTimeWhenValidate(from: "updateLeftHandleSeek") else { return }
        setTimeGap(from: "updateLeftHandleSeek")
        delegate?.updateCropTime(start: cropTime.start, end: cropTime.end)
        delegate?.seekTo(time: cropTime.start, handleType: .left)
    }
    
    func updateRightHandleSeek() {
        guard updateCropTimeWhenValidate(from: "updateRightHandleSeek") else { return }
        setTimeGap(from: "updateRightHandleSeek")
        delegate?.updateCropTime(start: cropTime.start, end: cropTime.end)
        delegate?.seekTo(time: cropTime.end, handleType: .right)
        
    }
    
    func updateTrimTime(time: CMTime, handleType: SLVideoEditorSliderHandleType) {
        
    }
    
}

extension SLVideoEditorSliderView: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.videoFramesView.updateMaskDim(CGRect(x: self.leftHandleOffset, y: 0, width: self.rightHandleOffset - self.leftHandleOffset, height: 60))
        updateLeftHandleSeek()
    }
    
    func updateTime(time: Float) {
        handleView.updateTime(time: time)
    }
    
    func updateTimeToStart() {
        handleView.updateTimeToStart()
    }
    
    func setSliderVisible(_ visible: Bool) {
        handleView.setSliderVisible(visible)
    }
}
