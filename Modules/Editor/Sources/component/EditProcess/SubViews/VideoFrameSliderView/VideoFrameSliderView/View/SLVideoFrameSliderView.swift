//
//  SLVideoFrameSliderView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/13/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit


class SLVideoFrameSliderView : UIView, SLReactor {
    
    
    enum Action {
        //videoUrl setting 되고 나서 초기화 시작
        case initialize
        case resetAndRedraw
        case calculateFrameSize
        case scrollTo(CGFloat)
        case setVideoUrl(URL)
        case setVideoTrimMode(SLVideoFrameSliderReactor.Mode)
        case changeThumbnailFrameToPickerImage(UIImage?)
    }
    
    enum Result {
        case scrollDidScroll(cv : UICollectionView)
        case scrollDidStopScrolling(cv : UICollectionView)
        case imageGeneratorFinished
        case setTimePerPixel(CGFloat)
        case setPixelPerTime(CGFloat)
        case setVideoDuration(CGFloat)
    }
    
    
    lazy private var frameCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset =  UIEdgeInsets(top: 0, left: SLEditProcessCommon.trimPadding, bottom: 0, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        reactor.action( .registerCv(cv) )
        cv.alwaysBounceHorizontal = false
        cv.alwaysBounceVertical = false
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.bounces = false
        cv.backgroundColor = .clear
        return cv
    }()
   
    var resultHandler: ((Result) -> ())?
    
    private let reactor : SLVideoFrameSliderReactor = SLVideoFrameSliderReactor()

    override init(frame : CGRect) {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        bindReactor()
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
        case .initialize:
            self.onInitialize()
        case .setVideoUrl(let url):
            self.onSetVideoUrl(url: url)
        case .setVideoTrimMode(let mode):
            self.onSetVideoTrimMode(mode: mode)
        case .calculateFrameSize:
            reactor.action( .calculateFrameSize )
        case .resetAndRedraw:
            reactor.action( .resetAndRedraw )
        case .scrollTo(let offset):
            self.onScrollTo(offset: offset)
        case .changeThumbnailFrameToPickerImage(let pickerImage):
            self.onChangeThumbnailFrameToPickerImage(pickerImage: pickerImage)
        }
    }
    
    private func onInitialize() {
        reactor.action( .viewDidLoad )
        reactor.action( .calculateFrameSize )
    }
    
    private func onSetVideoUrl(url : URL) {
        reactor.action( .setVideoUrl(url) )
    }
    
    private func onSetVideoTrimMode(mode : SLVideoFrameSliderReactor.Mode) {
        reactor.action( .setTrimMode(mode) )
    }
    
    private func onScrollTo(offset : CGFloat) {
        reactor.action( .setBlockScrollDidScrollEvent(true) )
        frameCollectionView.contentOffset.x = offset
        reactor.action( .setBlockScrollDidScrollEvent(false) )
    }
    
    private func onChangeThumbnailFrameToPickerImage(pickerImage : UIImage?) {
        reactor.action( .changeThumbnailFrameToPickerImage(pickerImage) )
    }
    
    
    private func bindReactor() {
        reactor.resultHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                switch result {
                case .scrollDidScroll(cv: let cv):
                    self.resultHandler?( .scrollDidScroll(cv: cv) )
                case .scrollDidStopScrolling(cv: let cv):
                    self.resultHandler?( .scrollDidStopScrolling(cv: cv) )
                case .imageGeneratorFinished:
                    self.resultHandler?( .imageGeneratorFinished )
                case .setTimePerPixel(let timePerPixel):
                    self.resultHandler?( .setTimePerPixel(timePerPixel) )
                case .setPixelPerTime(let pixelPerTime):
                    self.resultHandler?( .setPixelPerTime(pixelPerTime) )
                case .setVideoDuration(let videoDuration):
                    self.resultHandler?( .setVideoDuration(videoDuration ))
                }
            }
        }
    }
    
}
extension SLVideoFrameSliderView {
    private func setLayout() {
        self.addSubview(frameCollectionView)
        NSLayoutConstraint.activate([
            frameCollectionView.topAnchor.constraint(equalTo: self.topAnchor),
            frameCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            frameCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            frameCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
//MARK: - Getter
extension SLVideoFrameSliderView {
    func getFirstThumbnailImage() -> UIImage {
        return reactor.getFirstThumbnailImage()
    }
    
    func getMaxTrimTime() -> CGFloat {
        return reactor.getMaxTrimTime()
    }
    
    func getMinTrimTime() -> CGFloat {
        return reactor.getMinTrimTime()
    }
    
    func getVideoDuration() -> CGFloat {
        return reactor.getVideoDuration()
    }
    
    func getCurrentContentOffsetX() -> CGFloat {
        return self.frameCollectionView.contentOffset.x
    }
    
    func getCollectionViewSize() -> CGSize {
        return self.frameCollectionView.frame.size
    }
    
    func getCollectionContentViewSize() -> CGSize {
        return self.frameCollectionView.contentSize
    }
}
