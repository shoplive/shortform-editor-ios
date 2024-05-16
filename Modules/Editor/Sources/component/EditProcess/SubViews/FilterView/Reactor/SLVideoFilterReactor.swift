//
//  SLVideoFilterReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/13/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit

class SLVideoFilterReactor: NSObject, SLReactor {
    
    enum Action {
        case viewDidLoad
        case viewDidLayoutSubView
        case viewDidAppear
        
        case setIntensity(CGFloat)
        
        case requestToggleVideoPlayOrPause
        case didPlayToEndTime
        case timeControlStatusUpdated(AVPlayer.TimeControlStatus)
        case requestOnConfirm
        case registerCv(UICollectionView)
        case initializeCells
    }
    
    enum Result {
        case setShortsVideo(ShortsVideo)
        case seekTo(CMTime)
        case setPlayerEndBoundaryTime(CMTime)
        
        case playVideo
        case pauseVideo
        
        case setFilterConfig(String)
        case requestOnConfirm(Bool)
        
        case setInitialIntensity(CGFloat)
    }
    
    
    private var videoEditInfoDto : SLVideoEditInfoDTO
    private var thumbnailImage : UIImage
    //ShopLiveShortformEditorFilterListManager.shared.filterList
    private var filterList : [Filters] = [
        .init(title: "a", content: CGETestCommands.adjustSaturationCommand),
        .init(title: "b", content: CGETestCommands.adjustExposureTestCommand),
        .init(title: "c", content: CGETestCommands.curveTestCommand),
        .init(title: "d", content: CGETestCommands.adjustCoolWhiteBalanceCommand)
    ]
    private var cv : UICollectionView?
    private var isViewAppeared : Bool = false
    private var isPlaying : Bool = false
    private var initialIntensity : CGFloat = 0.7
    private var initialFilterConfig : String = ""
    
    
    
    var resultHandler: ((Result) -> ())?
    
    init(videoEditInfoDto : SLVideoEditInfoDTO, thumbNailImage : UIImage) {
        self.videoEditInfoDto = videoEditInfoDto
        self.thumbnailImage = thumbNailImage
        super.init()
    }
    
    func action(_ action: Action) {
        switch action {
        case .viewDidLoad:
            self.onViewDidLoad()
        case .viewDidLayoutSubView:
            self.onViewDidLayoutSubView()
        case .viewDidAppear:
            self.onViewDidAppear()
        case .setIntensity(let intensity):
            self.onSetIntensity(intensity: intensity)
        case .registerCv(let cv):
            self.onRegisterCv(cv: cv)
        case .initializeCells:
            self.onInitializeCells()
        case .requestToggleVideoPlayOrPause:
            self.onRequestToggleVideoPlayOrPause()
        case .didPlayToEndTime:
            self.onDidPlayToEndTime()
        case .timeControlStatusUpdated(let timeControlStatus):
            self.onTimeControlStatusUpdated(status: timeControlStatus)
        case .requestOnConfirm:
            self.onRequestOnConfirm()
        }
    }
    
    private func onViewDidLoad() {
        resultHandler?( .setShortsVideo(videoEditInfoDto.shortsVideo) )
        resultHandler?( .setPlayerEndBoundaryTime(videoEditInfoDto.cropTime.end) )
        resultHandler?( .setFilterConfig(videoEditInfoDto.filterConfig?.filterConfig ?? "") )
        if let filterConfig =  videoEditInfoDto.filterConfig {
            self.initialIntensity = CGFloat(filterConfig.filterIntensity)
            self.initialFilterConfig = filterConfig.filterConfig
        }
        else {
            let filterConfig = SLFilterConfig(filterConfig: "", filterIntensity: 0.7)
            videoEditInfoDto.filterConfig = filterConfig
            self.initialIntensity = 0.7
            self.initialFilterConfig = ""
        }
        
    }
    
    private func onViewDidLayoutSubView() {
        if isViewAppeared == false {
            resultHandler?( .setInitialIntensity(self.initialIntensity) )
            resultHandler?( .setFilterConfig(self.initialFilterConfig) )
        }
    }
    
    private func onViewDidAppear() {
        guard isViewAppeared == false else { return }
        isViewAppeared = true
        self.resultHandler?( .seekTo(self.videoEditInfoDto.cropTime.start) )
        self.resultHandler?( .playVideo )
        
        //여기서 크롭 적용 할 건지 말건지 고민중
    }
    
    private func onSetIntensity(intensity : CGFloat) {
        self.videoEditInfoDto.filterConfig?.filterIntensity = Float(intensity)
    }
    
    
    private func onRegisterCv(cv : UICollectionView) {
        self.cv = cv
        cv.delegate = self
        cv.dataSource = self
        cv.register(SLVideoFilterCell.self, forCellWithReuseIdentifier: SLVideoFilterCell.cellId)
    }
    
    private func onInitializeCells() {
        cv?.visibleCells.compactMap({ $0 as? SLVideoFilterCell }).forEach({ cell  in
            cell.drawGLKView()
        })
    }
    
    private func onRequestToggleVideoPlayOrPause() {
        if isPlaying == false {
            resultHandler?( .playVideo )
        }
        else {
            resultHandler?( .pauseVideo )
        }
    }
    
    private func onDidPlayToEndTime() {
        resultHandler?( .seekTo(videoEditInfoDto.cropTime.start))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) { [weak self] in
            self?.resultHandler?( .playVideo )
        }
    }
    
    private func onTimeControlStatusUpdated(status : AVPlayer.TimeControlStatus) {
        if status == .playing {
            self.isPlaying = true
        }
        else {
            self.isPlaying = false
        }
    }
    
    private func onRequestOnConfirm() {
        if let fIntensity = videoEditInfoDto.filterConfig?.filterIntensity,
           CGFloat(fIntensity) == initialIntensity,
           initialFilterConfig == videoEditInfoDto.filterConfig?.filterConfig {
            resultHandler?( .requestOnConfirm(false) )
        }
        else {
            resultHandler?( .requestOnConfirm(true) )
        }
    }
    
}
extension SLVideoFilterReactor {
    
    
}
extension SLVideoFilterReactor : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout  {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cv = scrollView as? UICollectionView {
            cv.visibleCells.forEach { cell in
                if let cell = cell as? SLVideoFilterCell {
                    cell.drawGLKView()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SLVideoFilterCell.cellId, for: indexPath) as! SLVideoFilterCell
        
        let filter = filterList[indexPath.row]
        
        cell.setfilterName(filterName: filter.title ?? "")
        let isSelected = videoEditInfoDto.filterConfig?.filterConfig == filter.content
        cell.configure(filterConfig: filter.content ?? "" , isSelected: isSelected, thumbNail: self.thumbnailImage)
        

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 72, height: 96)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SLVideoFilterCell else { return }
        guard videoEditInfoDto.filterConfig?.filterConfig != filterList[indexPath.row].content else { return }
        
        if let oldSelectedIndexPath = filterList.firstIndex(where: { $0.content == videoEditInfoDto.filterConfig?.filterConfig }),
           oldSelectedIndexPath > 0,
           let oldCell = collectionView.cellForItem(at: IndexPath(row: oldSelectedIndexPath, section: 0)) as? SLVideoFilterCell{
            oldCell.setCellSelected(isSelected: false)
        }
        
        videoEditInfoDto.filterConfig?.filterConfig = filterList[indexPath.row].content ?? ""
        cell.setCellSelected(isSelected: true)
        resultHandler?( .setFilterConfig(filterList[indexPath.row].content ?? "") )
        
        
    }
}
