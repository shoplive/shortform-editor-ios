//
//  SLTimeTrimSliderView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/13/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon

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
class SLTimeTrimSliderView : UIView, SLReactor {
    
    enum Action {
        case resetAndRedraw
        case setPlaybackSpeed(CGFloat)
        case calculateTimeDuration
        case updateTimeIndicatorTime(Float)
        case updateTimeIndicatorTimeToStartPos
    }
    
    enum Result {
        case toggleViewPlayOrPause
        case seekTo(CMTime)
        case updateCropTime(start: CMTime, end: CMTime)
    }
    
    
    let frameSliderView : SLVideoFrameSliderView
    
    lazy private var handleView : SLVideoEditorSliderHandleView2 = {
        let view = SLVideoEditorSliderHandleView2(frame: .zero,timeIndicatorCornerRadius : timeIndicatorCornerRadius,
                                                  handleCornerRadius: handleCornerRadius,
                                                  handleBackgroundColor: handleBackgroundColor,
                                                  handleBarColor: handleBarColor,
                                                  timeIndicatorbackgroundColor : timeIndicatorbackgroundColor)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    var resultHandler: ((Result) -> ())?
    private var timeIndicatorCornerRadius : CGFloat = 0
    private var timeIndicatorbackgroundColor : UIColor = .white
    private var handleCornerRadius : CGFloat = 4
    private var handleBackgroundColor : UIColor = .white
    private var handleBarColor : UIColor = .white
    
    private let reactor = SLTimeTrimeSliderReactor()
    
    init(videoUrl : URL,
         timeIndicatorCornerRadius : CGFloat,
         timeIndicatorbackgroundColor: UIColor,
         handleCornerRadius : CGFloat,
         handleBackgroundColor : UIColor,
         handleBarColor : UIColor ) {
        self.timeIndicatorbackgroundColor = timeIndicatorbackgroundColor
        self.timeIndicatorCornerRadius = timeIndicatorCornerRadius
        self.frameSliderView = SLVideoFrameSliderView()
        frameSliderView.action( .setVideoUrl(videoUrl) )
        frameSliderView.action( .setVideoTrimMode(.timeTrim) )
        frameSliderView.action( .initialize )
        super.init(frame: .zero)
        self.handleCornerRadius = handleCornerRadius
        self.handleBackgroundColor = handleBackgroundColor
        self.handleBarColor = handleBarColor
        self.backgroundColor = .clear
        bindReactor()
        bindHandleView()
        bindFrameSliderView()
        setLayout()
    }
    
    required init(coder : NSCoder) {
        fatalError()
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        for subview in self.subviews {
            if subview.hitTest(self.convert(point, to: subview), with: event) != nil {
                return true
            }
        }
        return false
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .resetAndRedraw:
            self.onResetAndRedraw()
        case .setPlaybackSpeed(let speed):
            self.onSetPlaybackSpeed(speed : speed)
        case .calculateTimeDuration:
            self.onCalculateTimeDuration()
        case .updateTimeIndicatorTime(let value):
            self.onUpdateTimeIndicatorTime(value: value)
        case .updateTimeIndicatorTimeToStartPos:
            self.onUpdateTimeIndicatorTimeToStartPos()
        }
    }
    
    private func onResetAndRedraw() {
        frameSliderView.action( .resetAndRedraw )
    }
    
    private func onCalculateTimeDuration() {
        handleView.action( .calculateTimeDuration )
    }
    
    private func onSetPlaybackSpeed(speed : CGFloat) {
        handleView.action( .setPlaybackSpeed(speed) )
    }
    
    private func onUpdateTimeIndicatorTime(value : Float) {
        reactor.action( .updateTimeIndicatorTime(value) )
    }
    
    private func onUpdateTimeIndicatorTimeToStartPos() {
        handleView.action( .updateTimeIndicatorToStartPos )
    }
    
    
}
//MARK: - bind Reactor
extension SLTimeTrimSliderView {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .cropTimeUpdated((let startTime, let endTime)):
                    self.onReactorCropTimeUpdated(startTime: startTime, endTime: endTime)
                case .seekTo(let time):
                    self.onReactorSeekTo(time: time)
                case .initializeHandleView((let startTime, let endTime)):
                    self.onReactorInitializeHandleView(startTime: startTime, endTime: endTime)
                case .updateTimeIndicatorTime(let time):
                    self.onReactorUpdateTimeIndicatorTime(time: time)
                }
            }
        }
    }
    
    private func onReactorCropTimeUpdated(startTime : CMTime, endTime : CMTime) {
        resultHandler?( .updateCropTime(start: startTime, end: endTime) )
        handleView.action( .updateTimeIndicatorSlider(startTime: startTime, endTime: endTime) )
    }
    
    private func onReactorSeekTo(time : CMTime) {
        resultHandler?( .seekTo(time) )
    }
    
    private func onReactorInitializeHandleView(startTime : CMTime, endTime : CMTime) {
        handleView.timebarLoaded = true
        handleView.action( .updateTimeIndicatorSlider(startTime: startTime, endTime: endTime) )
        handleView.resetAndRedraw()
        handleView.action( .initializeTimeIndicatorView )
    }
    
    private func onReactorUpdateTimeIndicatorTime(time : Float) {
        handleView.action( .updateTimeIndicatorTime(time) )
    }
}
//MARK: - bind FrameSlider
extension SLTimeTrimSliderView {
    private func bindFrameSliderView() {
        frameSliderView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .imageGeneratorFinished:
                self.onFrameSliderImageGeneratorFinished()
            case .scrollDidScroll(cv: let cv):
                self.onFrameSliderScrollDidScroll(cv: cv)
            case .scrollDidStopScrolling(cv: let _):
                self.onFrameSliderScrollDidStopScrolling()
            case .setTimePerPixel(let value):
                self.onFrameSliderSetTimePerPixel(value: value)
            case .setPixelPerTime(let value):
                self.onFrameSliderSetPixelPerTime(value: value)
            case .setVideoDuration(let duration):
                self.onFrameSliderSetVideoDuration(duration: duration)
            }
        }
    }
    
    private func onFrameSliderImageGeneratorFinished() {
        reactor.action( .initializeHandleView )
    }
    
    private func onFrameSliderScrollDidScroll(cv : UICollectionView) {
        reactor.action( .frameSliderDidScroll(cv) )
        reactor.action( .setIsDraggin(true) )
    }
    
    private func onFrameSliderScrollDidStopScrolling() {
        reactor.action( .setIsDraggin(false) )
    }
    
    private func onFrameSliderSetTimePerPixel(value : CGFloat) {
        reactor.action( .setTimePerPixel(value) )
        handleView.setTimePerPixel(timePerPixel: value)
    }
    
    private func onFrameSliderSetPixelPerTime(value : CGFloat) {
        handleView.setPixelPerTime(pixelPerTime: value)
    }
    private func onFrameSliderSetVideoDuration(duration : Double) {
        handleView.action( .setVideoDuration(duration) )
        reactor.action( .setVideoDuration(duration) )
    }
    
    
}
//MARK: - bindHandleView
extension SLTimeTrimSliderView {
    private func bindHandleView() {
        handleView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .handleDidStartDragging:
                self.onHandleDidStartDragging()
            case .handleDidFinishDragging:
                self.onHandleDidFinishDragging()
            case .timeIndicatordidFinishDragging:
                self.onHandleDidFinishDragging()
            case .timeIndicatordidStartDraggin:
                self.onHandleDidStartDragging()
            case .updateCurrenHandlePosition(let offset, let handleType):
                self.onHandleViewUpdateCurrentHandlePosition(offset: offset, handleType: handleType)
            case .thumbViewOffsetChanged(let offset):
                self.onHandleViewThumbViewOffsetChanged(offset : offset)
            }
        }
    }
    
    
    private func onHandleDidFinishDragging() {
        resultHandler?( .toggleViewPlayOrPause )
        reactor.action( .setIsDraggin(false) )
    }
    
    private func onHandleDidStartDragging() {
        resultHandler?( .toggleViewPlayOrPause)
        reactor.action( .setIsDraggin(true) )
    }
    
    //timeInidicatorView 움직였을때 발생하는 이벤트
    private func onHandleViewThumbViewOffsetChanged(offset: CGFloat) {
        reactor.action( .convertHandlePositionToTime(offset: offset, handleType: .timeIndicator, contentOffset: frameSliderView.getCurrentContentOffsetX()))
    }
    
    //offset 넘겨줌
    private func onHandleViewUpdateCurrentHandlePosition(offset: CGFloat, handleType: SLVideoEditorSliderHandleType) {
        if handleType == .left {
            reactor.action( .setLeftHandleOffset(offset) )
        }
        else {
            reactor.action( .setRighHandleOffset(offset) )
        }
        
        reactor.action( .convertHandlePositionToTime(offset: offset, handleType: handleType, contentOffset: frameSliderView.getCurrentContentOffsetX()))
    }
}
extension SLTimeTrimSliderView {
    private func setLayout() {
        self.addSubview(frameSliderView)
        frameSliderView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(handleView)
        
        NSLayoutConstraint.activate([
            frameSliderView.topAnchor.constraint(equalTo: self.topAnchor),
            frameSliderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            frameSliderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            frameSliderView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            
            handleView.topAnchor.constraint(equalTo: self.topAnchor),
            handleView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            handleView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            handleView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
    }
}
//MARK: - GETTER
extension SLTimeTrimSliderView {
    func getFirstThumbnailImage() -> UIImage {
        return frameSliderView.getFirstThumbnailImage()
    }
}
