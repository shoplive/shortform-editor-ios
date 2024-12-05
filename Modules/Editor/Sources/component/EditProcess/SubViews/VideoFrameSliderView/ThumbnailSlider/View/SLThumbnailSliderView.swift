//
//  SLThumbnailSliderView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/14/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon

class SLThumbnailSliderView : UIView,SLReactor {
    
    enum Action {
        // videoUrl setting 되고 나서 초기화 시작
        case initializeSliderView
        case initializeThumbView
        case seekToHandleViewTo(CMTime)
        case setVideoUrl(URL)
        
        case changeThumbnailFrameToPickerImage(UIImage?)
    }
    
    enum Result {
        case seekTo(CMTime)
    }
    
    let frameSliderView : SLVideoFrameSliderView
    
    lazy private var dimView : SLThumbnailSliderDimView = {
        let view = SLThumbnailSliderDimView(frame: .zero, cornerRadius: self.containerCornerRadius)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy private var handleView : SLThumbnailSliderHandleView = {
        let view = SLThumbnailSliderHandleView(frame: .zero, borderColor: self.thumbViewBorderColor, cornerRadius: self.thumbViewCornerRadius)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var resultHandler: ((Result) -> ())?
    
    private let reactor = SLThumbnailSliderReactor()
    private var containerCornerRadius : CGFloat = 0
    private var thumbViewBorderColor : UIColor = .white
    private var thumbViewCornerRadius : CGFloat = 8
    
    init(containerCornerRadius : CGFloat, thumbViewBorderColor : UIColor,thumbviewCornerRadius : CGFloat) {
        self.frameSliderView = SLVideoFrameSliderView()
        self.containerCornerRadius = containerCornerRadius
        self.thumbViewBorderColor = thumbViewBorderColor
        self.thumbViewCornerRadius = thumbviewCornerRadius
        super.init(frame: .zero)
        self.backgroundColor = .clear
        frameSliderView.layer.cornerRadius = 8
        bindReactor()
        bindHandleView()
        bindFrameSliderView()
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func action(_ action: Action) {
        switch action {
        case .initializeSliderView:
            self.onInitializeSliderView()
        case .setVideoUrl(let url):
            self.onSetVideoUrl(url: url)
        case .initializeThumbView:
            self.onInitializeThumbView()
        case .seekToHandleViewTo(let time):
            self.onSeekToHandleViewTo(time: time)
        case .changeThumbnailFrameToPickerImage(let pickerImage):
            self.onChangeThumbnailFrameToPickerImage(pickerImage: pickerImage)
        }
    }
    
    private func onInitializeSliderView() {
        frameSliderView.action( .initialize )
    }
    
    private func onSetVideoUrl(url : URL) {
        frameSliderView.action( .setVideoUrl(url) )
    }
    
    private func onInitializeThumbView() {
        handleView.action( .initializeThumbView )
        dimView.makeHandleViewAreaClear(rect: CGRect(origin: .init(x: handleView.getHandleMargin(), y: 0), size: .init(width: 60 * (CGFloat(9) / CGFloat(16)), height: 60)))
    }
    
    private func onSeekToHandleViewTo(time : CMTime) {
        reactor.action( .seekToHandleViewTo(targetTime: time, cvWidth: frameSliderView.getCollectionViewSize().width, cvContentSize: frameSliderView.getCollectionContentViewSize().width) )
    }
    
    private func onChangeThumbnailFrameToPickerImage(pickerImage : UIImage?) {
        handleView.isUserInteractionEnabled = pickerImage == nil
        frameSliderView.isUserInteractionEnabled = pickerImage == nil
        frameSliderView.action( .changeThumbnailFrameToPickerImage( pickerImage) )
    }
}
//MARK: - bind Reactor
extension SLThumbnailSliderView {
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .seekTo(let time):
                self.resultHandler?( .seekTo(time) )
            case .moveHandleViewTo(let offset):
                self.onReactorMoveHandleViewTo(offset: offset)
            case .scrollFrameSliderTo(let offset):
                self.onReactorScrollFrameSLiderTo(offset: offset)
            }
        }
    }
    
    private func onReactorMoveHandleViewTo(offset : CGFloat) {
        handleView.action( .moveHandleTo(offset) )
    }
    
    private func onReactorScrollFrameSLiderTo(offset : CGFloat) {
        frameSliderView.action( .scrollTo(offset) )
    }

}
//MARK: - bind FrameSlider
extension SLThumbnailSliderView {
    private func bindFrameSliderView() {
        frameSliderView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .setTimePerPixel(let value):
                self.onFrameSliderSetTimePerPixel(value: value)
            case .scrollDidScroll(cv: let cv):
                self.onFrameSliderScrollDidScroll(cv: cv)
            default:
                break
            }
        }
    }
    
    private func onFrameSliderSetTimePerPixel(value : CGFloat) {
        reactor.action( .setTimePerPixel(value) )
        handleView.action( .setTimePerPixel(value) )
    }
    
    private func onFrameSliderScrollDidScroll(cv : UICollectionView) {
        reactor.action( .frameSliderDidScroll(cv) )
    }
}
//MARK: - bind handleView
extension SLThumbnailSliderView {
    private func bindHandleView() {
        handleView.resultHandler = { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .thumbViewOffset(let offset):
                self.onHandleViewThumbViewOffsetChanged(offset : offset)
            case .thumbViewOffsetForDimViewOnly(let offset):
                self.onHandleViewThumbViewOffsetForDimViewOnly(offset: offset)
            }
        }
    }
    
    private func onHandleViewThumbViewOffsetChanged(offset: CGFloat) {
        reactor.action( .convertHandlePositionToTime(offset: offset, contentOffset: frameSliderView.getCurrentContentOffsetX()))
        dimView.makeHandleViewAreaClear(rect: CGRect(origin: .init(x: offset, y: 0), size: .init(width: 60 * (CGFloat(9) / CGFloat(16)), height: 60)))
    }
    
    private func onHandleViewThumbViewOffsetForDimViewOnly(offset : CGFloat) {
        dimView.makeHandleViewAreaClear(rect: CGRect(origin: .init(x: offset, y: 0), size: .init(width: 60 * (CGFloat(9) / CGFloat(16)), height: 60)))
    }
}
extension SLThumbnailSliderView {
    private func setLayout() {
        self.addSubview(frameSliderView)
        frameSliderView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(dimView)
        self.addSubview(handleView)
        
        NSLayoutConstraint.activate([
            frameSliderView.topAnchor.constraint(equalTo: self.topAnchor),
            frameSliderView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            frameSliderView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            frameSliderView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            dimView.topAnchor.constraint(equalTo: self.topAnchor),
            dimView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            dimView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            dimView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            handleView.topAnchor.constraint(equalTo: self.topAnchor,constant: -2),
            handleView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            handleView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            handleView.bottomAnchor.constraint(equalTo: self.bottomAnchor,constant: 2)
        ])
    }
}
