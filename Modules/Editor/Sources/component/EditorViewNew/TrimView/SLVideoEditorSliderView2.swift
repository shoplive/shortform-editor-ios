//
//  SLVideoEditorSliderView2.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 11/8/23.
//

import Foundation
import UIKit
import AVKit
import ShopliveSDKCommon


class SLVideoEditorSliderView2 : UIView {
    
    
    
    lazy private var frameCollectionView : UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.sectionInset =  UIEdgeInsets(top: 0, left: 28, bottom: 0, right: 0)
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.register(SLVideoEditorTrimFrameCell.self, forCellWithReuseIdentifier: SLVideoEditorTrimFrameCell.cellId)
        cv.register(SLVideoEditorFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SLVideoEditorFooterView.viewId)
        cv.delegate = self
        cv.dataSource = self
        cv.alwaysBounceHorizontal = false
        cv.alwaysBounceVertical = false
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        cv.bounces = false
        cv.backgroundColor = .clear
        return cv
    }()
    
    private lazy var handleView: SLVideoEditorSliderHandleView2 = {
        let view = SLVideoEditorSliderHandleView2(frame: .zero)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()
    
    
    
    weak var delegate : SLVideoEditorSliderViewDelegate?
    private var collectionViewItemSize : CGSize = .zero
    private var collectionViewFooterSize : CGSize = .init(width: 100, height: 60)
    private var fullTrimWidth : CGFloat {
        if UIScreen.isLandscape_SL {
            let leftSafe = UIScreen.leftSafeArea_SL
            let righSafe = UIScreen.rightSafeArea_SL
            return UIScreen.main.bounds.width - (28 * 2) - (leftSafe + righSafe)
        }
        else {
            return UIScreen.main.bounds.width - (28 * 2)
        }
        
    }
    private let frameHeight : CGFloat = 60
    private var timePerPixel : CGFloat = 0
    private(set) var videoRatio: CGSize = CGSize(width: 9, height: 16)
    private(set) var videoUrl: URL?
    private var videoDuration: CGFloat = 0
    private var currentCropTime : (start: CMTime, end: CMTime) = (.zero, .zero)
    private var minTrimTime : CGFloat  {
        return ShopLiveShortformEditorConfigurationManager.shared.shortformUploadConfiguration?.videoTrimOption.minVideoDuration ?? 1
    }
    
    private var maxTrimTime : CGFloat {
        return ShopLiveShortformEditorConfigurationManager.shared.shortformUploadConfiguration?.videoTrimOption.maxVideoDuration ?? 60
    }
    
    private var imageGenerator : AVAssetImageGenerator
    private var imageGeneratorQueue = DispatchQueue(label: "shopLiveImageGeneratorQueue",qos: .background)
    private var leftHandleOffset : CGFloat = 0
    private var righthandleOffset : CGFloat = 0
    
    
    private var frameImages : [UIImage] = []
    
    
    init(videoUrl: URL) {
        self.videoUrl = videoUrl
        let asset = AVAsset(url: videoUrl)
        self.imageGenerator = AVAssetImageGenerator(asset: asset )
        self.imageGenerator.appliesPreferredTrackTransform = true
        self.imageGenerator.maximumSize = CGSize(width: 720, height: 1280)
        self.imageGenerator.apertureMode = .cleanAperture
        super.init(frame: .zero)
        self.backgroundColor = .black
        self.videoDuration = CGFloat(CMTimeGetSeconds(asset.duration))
        setLayout()
        
        calculateFrameSize()
        handleView.setTimePerPixel(timePerPixel: self.timePerPixel)
        handleView.setVideoDuration(videoDuration: self.videoDuration)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        ShopLiveLogger.debugLog("[ShopliveShortformEditor] SLVideoEditorSliderView2 deinited")
    }
    
    func resetAndRedraw() {
        self.frameImages.removeAll()
        self.calculateFrameSize()
        handleView.setTimePerPixel(timePerPixel: self.timePerPixel)
        handleView.setVideoDuration(videoDuration: self.videoDuration)
        handleView.resetAndRedraw()
    }
    
    private func calculateFrameSize(){
        if maxTrimTime >= round(self.videoDuration) {
            self.calculateFrameForMaxTrimTimeBiggerThenVideoDuration()
        }
        else {
            self.calculateFramesForMaxTrimTimeLowerThenVideoDuration()
        }
        
    }
    
    private func calculateFrameForMaxTrimTimeBiggerThenVideoDuration() {
        let estimatedWidthOfPerFrame = frameHeight * ( 9 / 16 )
        
        self.timePerPixel = (self.videoDuration / fullTrimWidth) // 1pixel당 시간
        
        let maxFrameCounts = ceil(fullTrimWidth / estimatedWidthOfPerFrame)//대략적인 크기로 대충 몇개로 나누어 떨어지는 지 계산
        
        let exactWidthOfPerFrame = fullTrimWidth / maxFrameCounts // 대략적인 cell의 개수대로 다시 정확한 cell의 width를 계산함
        
        collectionViewItemSize = .init(width: exactWidthOfPerFrame, height: frameHeight)
        
        let timePerFrame = exactWidthOfPerFrame * timePerPixel
        
        let totalTime = timePerFrame * maxFrameCounts
        
        var footerWidth : CGFloat
        if totalTime > self.videoDuration {
            let overedTime = totalTime - self.videoDuration
             footerWidth = exactWidthOfPerFrame - (overedTime / timePerPixel) + 28
        }
        else if totalTime == self.videoDuration {
             footerWidth = exactWidthOfPerFrame + 28
        }
        else {
            let shortageTime =  self.videoDuration - totalTime
             footerWidth = exactWidthOfPerFrame + (shortageTime / timePerPixel) + 28
        }
        self.collectionViewFooterSize = .init(width: footerWidth, height: 60)
        
        for i in 0 ... Int(maxFrameCounts) {
            let isEnd = (i == (Int(maxFrameCounts)))
            self.extractThumbnailsForNSec(targetSec: Double(timePerPixel) * Double(i) , isEnd: isEnd)
        }
    }
    
    private func calculateFramesForMaxTrimTimeLowerThenVideoDuration() {
        let WidthOfPerFrame = frameHeight * ( 9 / 16 )
        self.timePerPixel =  (maxTrimTime / fullTrimWidth) // 1pixel당 시간
        collectionViewItemSize = .init(width: WidthOfPerFrame, height: frameHeight)
        let timePerFrame : Double = Double(timePerPixel * WidthOfPerFrame)
        
        
        var frameCount : Double = 0
        var frameTargetTime : Double = frameCount * (timePerFrame)
        while frameTargetTime <= Double(self.videoDuration) {
            self.extractThumbnailsForNSec(targetSec: frameTargetTime,isEnd: false)
            frameCount += 1
            frameTargetTime = frameCount * (timePerFrame)
        }
        
        let totalTime = timePerFrame * frameCount
        
        var footerWidth : CGFloat
        if totalTime > self.videoDuration {
            let overedTime = totalTime - self.videoDuration
             footerWidth = WidthOfPerFrame - (overedTime / timePerPixel) + 28
        }
        else if totalTime == self.videoDuration {
             footerWidth = WidthOfPerFrame + 28
        }
        else {
            let shortageTime =  self.videoDuration - totalTime
             footerWidth = WidthOfPerFrame + (shortageTime / timePerPixel) + 28
        }
        self.collectionViewFooterSize = .init(width: footerWidth, height: 60)
        self.extractThumbnailsForNSec(targetSec: 0, isEnd: true)
    }
    
    
    private func extractThumbnailsForNSec(targetSec : Double, isEnd : Bool) {
        imageGeneratorQueue.sync { [weak self] in
            guard let self = self else { return }
            if isEnd {
                self.handleView.timebarLoaded = true
                self.reloadCollectionViewData()
                return
            }
            do {
                let time = CMTime(seconds: targetSec, preferredTimescale: 44100)
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                self.frameImages.append(UIImage.init(cgImage: cgImage))
            }
            catch(let error) {
                print("imageExtract Error \(error)")
            }
        }
    }
    
    
    private func reloadCollectionViewData() {
        self.handleView.timebarLoaded = true
        let timeIndicatorEndTime = min(self.videoDuration, self.maxTrimTime )
        currentCropTime.start = .init(seconds: 0, preferredTimescale: 44100)
        currentCropTime.end = .init(seconds: Double(timeIndicatorEndTime), preferredTimescale: 44100)
        handleView.updateTimeIndicatorSliderTime(start: currentCropTime.start, end: currentCropTime.end)
        handleView.resetAndRedraw()
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            (self.frameCollectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.invalidateLayout()
            self.frameCollectionView.reloadData()
        }
    }
    
    func setTimeIndicatorLineVisible(isVisible : Bool) {
        handleView.setTimeIndicatorVisible(isVisible: isVisible)
    }
    
    func updateTimeIndicatorTimeToStartPos() {
        handleView.updateTimeIndicatorTimeToStartPos()
    }
    
    func updateTimeIndicatorTime(time : Float) {
        handleView.updateTimeIndicatorTime(time: time)
    }

    
    
}
extension SLVideoEditorSliderView2 {
    private func setLayout(){
        self.addSubview(frameCollectionView)
        self.addSubview(handleView)
        
        NSLayoutConstraint.activate([
            frameCollectionView.topAnchor.constraint(equalTo: self.topAnchor),
            frameCollectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            frameCollectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            frameCollectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            
            handleView.topAnchor.constraint(equalTo: self.topAnchor),
            handleView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            handleView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            handleView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
}
extension SLVideoEditorSliderView2 : UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return UICollectionReusableView()
        case UICollectionView.elementKindSectionFooter:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SLVideoEditorFooterView.viewId, for: indexPath) as! SLVideoEditorFooterView
            if let last = frameImages.last {
                header.setImage(image: last)
            }
            return header
        default:
            return UICollectionReusableView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return self.collectionViewFooterSize
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return frameImages.count - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SLVideoEditorTrimFrameCell.cellId, for: indexPath) as! SLVideoEditorTrimFrameCell
        
        cell.setImage(image: frameImages[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.collectionViewItemSize
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentCollectionViewOffset = self.frameCollectionView.contentOffset.x
        let realOffset = currentCollectionViewOffset + leftHandleOffset
        let time = realOffset * timePerPixel
        currentCropTime.start = CMTime(seconds: Double(time), preferredTimescale: 44100)
        updateLeftHandleSeek()
    }
}
extension SLVideoEditorSliderView2 : SLVideoEditorSliderHandleDelegate {
    //offset 넘겨줌
    func updatedCurrentHandlePosition(offset: CGFloat, handleType: SLVideoEditorSliderHandleType) {
        if handleType == .left {
            self.leftHandleOffset = offset
            let startTime = self.convertHandlePositionToTime(position : offset, handelType : handleType)
            currentCropTime.start = startTime
            updateLeftHandleSeek()
        }
        else {
            self.righthandleOffset = offset
            let endtime = self.convertHandlePositionToTime(position : offset, handelType : handleType)
            currentCropTime.end = endtime
            updateRightHandleSeek()
        }
    }
    
    private func convertHandlePositionToTime(position : CGFloat, handelType : SLVideoEditorSliderHandleType) -> CMTime {
        let currentCollectionViewOffset = self.frameCollectionView.contentOffset.x
        let realOffset = currentCollectionViewOffset + position
        let time = realOffset * timePerPixel
        return CMTime(seconds: Double(time), preferredTimescale: 44100)
    }
    
    
    private func updateLeftHandleSeek() {
        handleView.updateTimeIndicatorSliderTime(start: currentCropTime.start, end: currentCropTime.end)
        delegate?.updateCropTime(start: currentCropTime.start, end: currentCropTime.end)
        delegate?.seekTo(time: currentCropTime.start, handleType: .left)
    }
    
    private func updateRightHandleSeek() {
        handleView.updateTimeIndicatorSliderTime(start: currentCropTime.start, end: currentCropTime.end)
        delegate?.updateCropTime(start: currentCropTime.start, end: currentCropTime.end)
        delegate?.seekTo(time: currentCropTime.end, handleType: .right)
    }
    
//    private func getVideoTimeByHandlePosition(handleType: SLVideoEditorSliderHandleType) -> CMTime {
//        
//    }
}
