//
//  SLVideoFrameSliderReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/13/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit

class SLVideoFrameSliderReactor : NSObject, SLReactor {
    typealias globalConfig = ShopLiveEditorConfigurationManager
    
    enum Action {
        case viewDidLoad
        case calculateFrameSize
        case resetAndRedraw
        case registerCv(UICollectionView)
        case setBlockScrollDidScrollEvent(Bool)
        case setVideoUrl(URL)
        case setTrimMode(Mode)
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
    
    
    enum Mode {
        case timeTrim
        case thumbnail
    }
    
    private var cv : UICollectionView?
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
    private var pixelPerTime : CGFloat = 0
    
    private var videoRatio: CGSize = CGSize(width: 9, height: 16)
    private var videoUrl: URL?
    private var videoAsset : AVAsset?
    private var videoDuration: CGFloat = 0
    private var minTrimTime : CGFloat  {
        return globalConfig.shared.videoTrimOption.minVideoDuration
    }
    
    private var maxTrimTime : CGFloat {
        return globalConfig.shared.videoTrimOption.maxVideoDuration
    }
    
    private var imageGenerator : AVAssetImageGenerator?
    private var imageGeneratorQueue = DispatchQueue(label: "shopLiveImageGeneratorQueue",qos: .background)
    private var maxFrameCounts : Int = 0
    private var newFrameImageDataSource : [Int : UIImage] = [:]
    private var index2timeDict : [Int : Double] = [:]
    private var time2ImageDict : [Double : UIImage] = [:]
    private var lastFrameTargetTime : Double = 0
    private var pickerImage : UIImage?
    
    private var blockScrollDidScrollEvent : Bool = false
    private var currentMode : Mode = .timeTrim
    
    
    var resultHandler: ((Result) -> ())?
    
    override init() {
        super.init()
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewDidLoad:
            self.onViewDidLoad()
        case .calculateFrameSize:
            self.onCalculateFrameSize()
        case .resetAndRedraw:
            self.onResetAndRedraw()
        case .registerCv(let cv):
            self.onRegisterCv(cv: cv)
        case .setBlockScrollDidScrollEvent(let block):
            self.onBlockScrollDidScrollEvent(block: block)
        case .setVideoUrl(let url):
            self.onSetVideoUrl(url: url)
        case .setTrimMode(let mode):
            self.onSetTrimMode(mode: mode)
        case .changeThumbnailFrameToPickerImage(let pickerImage):
            self.onChangeThumbnailFrameToPickerImage(pickerImage : pickerImage)
        }
    }
    
    private func onViewDidLoad() {
        if let asset = videoAsset {
            self.videoDuration = CGFloat(CMTimeGetSeconds(asset.duration))
        }
    }
    
    private func onCalculateFrameSize() {
        if maxTrimTime >= round(self.videoDuration) {
            self.calculateFrameForMaxTrimTimeBiggerThenVideoDuration()
        }
        else {
            self.calculateFramesForMaxTrimTimeLowerThenVideoDuration()
        }
    }
    
    private func onResetAndRedraw() {
        self.onCalculateFrameSize()
    }
    
    private func onRegisterCv(cv : UICollectionView) {
        self.cv = cv
        cv.register(SLVideoEditorTrimFrameCell.self, forCellWithReuseIdentifier: SLVideoEditorTrimFrameCell.cellId)
        cv.register(SLVideoEditorFooterView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SLVideoEditorFooterView.viewId)
        cv.delegate = self
        cv.dataSource = self
    }
    
    private func onBlockScrollDidScrollEvent(block : Bool) {
        self.blockScrollDidScrollEvent = block
    }
    
    private func onSetVideoUrl(url : URL) {
        self.videoUrl = url
        videoAsset = AVAsset(url: url)
        self.imageGenerator = AVAssetImageGenerator(asset: videoAsset! )
        self.imageGenerator?.appliesPreferredTrackTransform = true
        self.imageGenerator?.maximumSize = CGSize(width: 720, height: 1280)
        self.imageGenerator?.apertureMode = .cleanAperture
    }
    
    private func onSetTrimMode(mode : Mode) {
        self.currentMode = mode
    }
    
    private func onChangeThumbnailFrameToPickerImage(pickerImage : UIImage?) {
        self.pickerImage = pickerImage
        self.cv?.reloadData()
    }
}
//MARK: - Frame Calculation
extension SLVideoFrameSliderReactor {
    private func calculateFrameForMaxTrimTimeBiggerThenVideoDuration() {
        
        let estimatedWidthOfPerFrame = frameHeight * ( 9 / 16 )
        
        var extraTrimWidth : CGFloat = 0
        
        if currentMode == .thumbnail {
            extraTrimWidth = frameHeight * ( 9 / 16 )
        }
        
        self.timePerPixel = (self.videoDuration / (fullTrimWidth + extraTrimWidth)) // 1pixel당 시간
        
        self.pixelPerTime = ( (fullTrimWidth + extraTrimWidth) / self.videoDuration ) // 1초당 pixel
        
        let maxFrameCounts = ceil((fullTrimWidth + extraTrimWidth) / estimatedWidthOfPerFrame)//대략적인 크기로 대충 몇개로 나누어 떨어지는 지 계산
        
        let exactWidthOfPerFrame = (fullTrimWidth + extraTrimWidth) / maxFrameCounts // 대략적인 cell의 개수대로 다시 정확한 cell의 width를 계산함
        
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
            index2timeDict[i] = Double(timePerFrame) * Double(i)
            lastFrameTargetTime = max(Double(timePerFrame) * Double(i),lastFrameTargetTime)
        }
        self.maxFrameCounts = Int(maxFrameCounts)
        self.reloadCollectionViewData()
    }
    
    private func calculateFramesForMaxTrimTimeLowerThenVideoDuration() {
        let WidthOfPerFrame = frameHeight * ( 9 / 16 )
        self.timePerPixel =  (maxTrimTime / fullTrimWidth) // 1pixel당 시간
        self.pixelPerTime = ( fullTrimWidth / maxTrimTime ) // 1초당 pixel
        collectionViewItemSize = .init(width: WidthOfPerFrame, height: frameHeight)
        let timePerFrame : Double = Double(timePerPixel * WidthOfPerFrame)
        
        var extraVideoDuration : CGFloat = 0
        
        if currentMode == .thumbnail {
            extraVideoDuration = (frameHeight * ( 9 / 16 )) * timePerPixel
        }
        
        var frameCount : Double = 0
        var frameTargetTime : Double = frameCount * (timePerFrame)
        while frameTargetTime <= Double(self.videoDuration + extraVideoDuration) {
            index2timeDict[Int(frameCount)] = frameTargetTime
            lastFrameTargetTime = max(frameTargetTime,lastFrameTargetTime)
            frameCount += 1
            frameTargetTime = frameCount * (timePerFrame)
        }
        
        self.maxFrameCounts = Int(frameCount)
        
        let totalTime = timePerFrame * frameCount
        
        var footerWidth : CGFloat
        if totalTime > (self.videoDuration + extraVideoDuration) {
            let overedTime = totalTime - (self.videoDuration + extraVideoDuration)
             footerWidth = WidthOfPerFrame - (overedTime / timePerPixel) + 28
        }
        else if totalTime == (self.videoDuration + extraVideoDuration) {
             footerWidth = WidthOfPerFrame + 28
        }
        else {
            let shortageTime =  (self.videoDuration + extraVideoDuration) - totalTime
             footerWidth = WidthOfPerFrame + (shortageTime / timePerPixel) + 28
        }
        self.collectionViewFooterSize = .init(width: footerWidth, height: 60)
        self.reloadCollectionViewData()
    }
    
    private func reloadCollectionViewData() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
            let cv = self.cv else { return }
            (cv.collectionViewLayout as? UICollectionViewFlowLayout)?.invalidateLayout()
            cv.reloadData()
            self.resultHandler?( .setVideoDuration(self.videoDuration) )
            self.resultHandler?( .setPixelPerTime(self.pixelPerTime) )
            self.resultHandler?( .setTimePerPixel(self.timePerPixel) )
            self.resultHandler?( .imageGeneratorFinished )
        }
    }
    
    
}
extension SLVideoFrameSliderReactor : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            return UICollectionReusableView()
        case UICollectionView.elementKindSectionFooter:
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: SLVideoEditorFooterView.viewId, for: indexPath) as! SLVideoEditorFooterView
            if let image = self.pickerImage {
                header.setImage(image: image)
            }
            else if let image = time2ImageDict[lastFrameTargetTime] {
                header.setImage(image: image)
            }
            else {
                self.extractThumbnailsForNSec(targetSec: lastFrameTargetTime) { [weak self] image in
                    guard let self = self else { return }
                    self.time2ImageDict[self.lastFrameTargetTime] = image
                    DispatchQueue.main.async {
                        header.setImage(image: image)
                    }
                }
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
        return self.maxFrameCounts - 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SLVideoEditorTrimFrameCell.cellId, for: indexPath) as! SLVideoEditorTrimFrameCell
        
        if let pickerImage = pickerImage {
            cell.setImage(image: pickerImage )
        }
        else {
            if let targetTime = index2timeDict[indexPath.row] {
                if let image = time2ImageDict[targetTime] {
                    cell.setImage(image: image )
                }
                else {
                    self.extractThumbnailsForNSec(targetSec: targetTime) { [weak self] image in
                        guard let self = self else { return }
                        DispatchQueue.main.async {
                            self.time2ImageDict[targetTime] = image
                            if let pickerImage = self.pickerImage {
                                cell.setImage(image: pickerImage)
                            }
                            else {
                                cell.setImage(image: image)
                            }
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    
    private func extractThumbnailsForNSec(targetSec : Double, completion : @escaping(UIImage) -> ()) {
        imageGeneratorQueue.async { [weak self] in
            guard let self = self else { return }
            do {
                let time = CMTime(seconds: targetSec, preferredTimescale: 44100)
                if let cgImage = try self.imageGenerator?.copyCGImage(at: time, actualTime: nil) {
                    completion(UIImage.init(cgImage: cgImage))
                }
            }
            catch(let error) {
                print("imageExtract Error \(error)")
            }
        }
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
        guard let cv = cv else { return }
        guard blockScrollDidScrollEvent == false else { return }
        resultHandler?( .scrollDidScroll(cv: cv) )
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let cv = cv else { return }
        resultHandler?( .scrollDidStopScrolling(cv: cv) )
    }
    
    
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let cv = cv else { return }
        guard blockScrollDidScrollEvent == false else { return }
        if decelerate == false {
            resultHandler?( .scrollDidStopScrolling(cv: cv) )
        }
    }
}
//MARK: - Getter
extension SLVideoFrameSliderReactor {
    func getFirstThumbnailImage() -> UIImage {
        let firstFrameImage = time2ImageDict.sorted(by: { $0.key < $1.key }).first?.value
        return firstFrameImage ?? ShopLiveShortformEditorSDKAsset.slIcHotAirBallon.image
    }
    
    func getMaxTrimTime() -> CGFloat {
        return self.maxTrimTime
    }
    
    func getMinTrimTime() -> CGFloat {
        return self.minTrimTime
    }
    
    func getVideoDuration() -> CGFloat {
        return self.videoDuration
    }
}
