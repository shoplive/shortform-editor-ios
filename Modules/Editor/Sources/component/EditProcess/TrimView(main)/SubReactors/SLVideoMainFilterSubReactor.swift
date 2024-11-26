//
//  SLVideoMainFilterSubReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/24/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon
import AVKit


class SLVideoMainFilterSubReactor : NSObject, SLReactor {
    
    
    
    enum Action {
        case initialize
        case initializeCells
        case videoEditInfoDto(SLVideoEditInfoDTO)
        case setThumbnailImage(UIImage)
        case registerCv(UICollectionView)
        case setIntensity(CGFloat)
        case setToOrigin
        case onConfirm
        
    }
    
    enum Result {
        case setFilterConfig(String)
        case setInitialIntensity(CGFloat)
        case activateSlider(Bool)
        case confirmedWithChange
        case confirmedWithOrigin
    }
    
    
    var resultHandler: ((Result) -> ())?
    
    private var videoEditInfoDTO : SLVideoEditInfoDTO?
    private var thumbnailImage : UIImage?
//
    
    private var filterList : [Filters] = [Filters(title: ShopLiveShortformEditorSDKStrings.Editor.Filter.Origin.Cell.title, content: "", type: "CGE")] + ShopLiveShortformEditorFilterListManager.shared.filterList
    private var cv : UICollectionView?
    private var initialIntensity : CGFloat = 0.7
    private var initialFilterConfig : String = ""
    
    private let defaultIntensity : CGFloat = 0.7
    private var defaultFilterConfig : String = ""
    
    override init() {
        super.init()
    }
    
    func action(_ action: Action) {
        switch action {
        case .initialize:
            self.onInitialize()
        case .initializeCells:
            self.onInitializeCells()
        case .videoEditInfoDto(let dto):
            self.onVideoEditInfoDto(dto: dto)
        case .setThumbnailImage(let image):
            self.onSetThumbnailImage(image: image)
        case .registerCv(let cv):
            self.onRegisterCv(cv: cv)
        case .setIntensity(let value):
            self.onSetIntensity(intensity: value)
        case .setToOrigin:
            self.onSetToOrigin()
        case .onConfirm:
            self.onConfirm()
        }
    }
    
    private func onInitialize() {
        // initialIntensity는 0 ~ 1 값이므로 슬라이더에는 * 100을 해주어서 넘겨야 됨
        resultHandler?( .setInitialIntensity(self.initialIntensity * 100) )
        resultHandler?( .setFilterConfig(self.initialFilterConfig) )
    }
    
    private func onInitializeCells() {
        cv?.visibleCells.compactMap({ $0 as? SLVideoFilterCell }).forEach({ cell  in
            cell.reDrawGLKViewOnReAppear()
        })
    }
    
    private func onVideoEditInfoDto(dto : SLVideoEditInfoDTO) {
        self.videoEditInfoDTO = dto
        guard let videoEditInfoDto = self.videoEditInfoDTO else { return }
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
    
    private func onSetThumbnailImage(image : UIImage)  {
        self.thumbnailImage = image
        self.cv?.reloadData()
    }
    
    private func onRegisterCv(cv : UICollectionView) {
        self.cv = cv
        cv.delegate = self
        cv.dataSource = self
        cv.register(SLVideoFilterCell.self, forCellWithReuseIdentifier: SLVideoFilterCell.cellId)
    }
    
    private func onSetIntensity(intensity : CGFloat) {
        guard let dto = self.videoEditInfoDTO else { return }
        dto.filterConfig?.filterIntensity = Float(intensity)
        resultHandler?( .setFilterConfig(""))
    }
    
    private func onSetToOrigin() {
        let filterConfig = SLFilterConfig(filterConfig: "", filterIntensity: 0.7)
        guard let videoEditInfoDto = self.videoEditInfoDTO else { return }
        videoEditInfoDto.filterConfig = filterConfig
        self.initialIntensity = 0.7
        self.initialFilterConfig = ""
        resultHandler?( .setFilterConfig(""))
        resultHandler?( .setInitialIntensity(self.initialIntensity) )
    }
    
    private func onConfirm() {
        guard let videoEditInfoDto = self.videoEditInfoDTO else { return }
        if videoEditInfoDto.filterConfig?.filterConfig ?? "" == defaultFilterConfig && videoEditInfoDto.filterConfig?.filterIntensity ?? 0.7 == Float(defaultIntensity) {
            resultHandler?( .confirmedWithOrigin )
        }
        else {
            resultHandler?( .confirmedWithChange )
        }
    }
}
extension SLVideoMainFilterSubReactor : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        
        cell.setfilterName(filterName: filter.localizedTitle())
        let isSelected = videoEditInfoDTO?.filterConfig?.filterConfig == filter.content
        cell.configure(filterConfig: filter.content ?? "" , isSelected: isSelected, thumbNail: self.thumbnailImage)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 72, height: 100) //96
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SLVideoFilterCell else { return }
        guard let videoEditInfoDto = self.videoEditInfoDTO else { return }
        guard videoEditInfoDto.filterConfig?.filterConfig != filterList[indexPath.row].content else { return }
        
        if let oldSelectedIndexPath = filterList.firstIndex(where: { $0.content == videoEditInfoDto.filterConfig?.filterConfig }),
           oldSelectedIndexPath >= 0,
           let oldCell = collectionView.cellForItem(at: IndexPath(row: oldSelectedIndexPath, section: 0)) as? SLVideoFilterCell{
            oldCell.setCellSelected(isSelected: false)
        }
        
        if indexPath.row == 0 {
            resultHandler?( .activateSlider(false) )
        }
        else {
            resultHandler?( .activateSlider(true) )
        }
        
        videoEditInfoDto.filterConfig?.filterConfig = filterList[indexPath.row].content ?? ""
        cell.setCellSelected(isSelected: true)
        resultHandler?( .setFilterConfig(filterList[indexPath.row].content ?? "") )
    }
    
}
