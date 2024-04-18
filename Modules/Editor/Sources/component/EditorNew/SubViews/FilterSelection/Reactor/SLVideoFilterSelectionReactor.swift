//
//  SLVideoFilterSelectionReactor.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/28/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon




class SLVideoFilterSelectionReactor : NSObject, SLReactor {
    
    enum Action {
        case registerCollectionView(UICollectionView)
        case initializeCells
        case setCurrentFilterIntensity(Float)
        case cancelCurrentFilter
    }
    
    enum Result {
        case filterConfigSelected(String)
        case setFilterIntensity(Float)
        case showCancelBtn(Bool)
        case showIntensitySlider(Bool)
        
    }

    var resultHandler: ((Result) -> ())?
    var mainQueueResultHandler : ((Result) -> ())?
    private var currentSelectedIndex : Int = -1
    private var currentFilterIntensity : Float = 0.5
    
    private var filterList : [String] = ShopLiveShortformEditorFilterListManager.shared.filterList.compactMap({ $0.content })
    
    private var cv : UICollectionView?
    
    
    
    
    func action(_ action: Action) {
        switch action {
        case .registerCollectionView(let cv):
            self.onRegisterCollectionView(cv: cv)
        case .initializeCells:
            self.onInitializeCells()
        case .setCurrentFilterIntensity(let intensity):
            self.onSetCurrentFilterIntensity(intensity: intensity)
        case .cancelCurrentFilter:
            self.onCancelCurrentFilter()
            break
        }
        
    }
    
    private func onRegisterCollectionView(cv : UICollectionView){
        self.cv = cv
        cv.delegate = self
        cv.dataSource = self
        cv.register(SLVideoFilterSelectionCell.self , forCellWithReuseIdentifier: SLVideoFilterSelectionCell.cellId)
    }
    
    private func onInitializeCells() {
        cv?.visibleCells.compactMap({ $0 as? SLVideoFilterSelectionCell }).forEach({ cell  in
            cell.drawGLKView()
        })
    }
    
    private func onSetCurrentFilterIntensity(intensity : Float) {
        self.currentFilterIntensity = intensity
    }
    
    private func onCancelCurrentFilter() {
        let indexPath = IndexPath(row: currentSelectedIndex, section: 0)
        guard let cell = self.cv?.cellForItem(at: indexPath) as? SLVideoFilterSelectionCell else { return }
        cell.setCellSelected(isSelected: false)
        UIView.animate(withDuration: 0.2) {
            cell.transform = .identity
        }
        currentSelectedIndex = -1
        currentFilterIntensity = 0.5
        resultHandler?( .setFilterIntensity(0.5) )
        resultHandler?( .filterConfigSelected("") )
        mainQueueResultHandler?( .showCancelBtn(false) )
        mainQueueResultHandler?( .showIntensitySlider(false) )
    }
    
}
extension SLVideoFilterSelectionReactor {
    
}
extension SLVideoFilterSelectionReactor : UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let cv = scrollView as? UICollectionView {
            cv.visibleCells.forEach { item in
                if let cell = item as? SLVideoFilterSelectionCell {
                    cell.drawGLKView()
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SLVideoFilterSelectionCell.cellId, for: indexPath) as! SLVideoFilterSelectionCell
        cell.configure(filterConfig: filterList[indexPath.row],isSelected: indexPath.row == currentSelectedIndex)
        
        let filters = filterList[indexPath.row]
        
        cell.setfilterName(filterName: filters)
        
        if currentSelectedIndex == indexPath.row {
            cell.transform = .init(scaleX: 1.1, y: 1.1)
        }
        else {
            cell.transform = .identity
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 56, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? SLVideoFilterSelectionCell else { return }
        guard currentSelectedIndex != indexPath.row else { return }
        
        if currentSelectedIndex >= 0, let oldCell = collectionView.cellForItem(at: IndexPath(row: currentSelectedIndex, section: 0)) as? SLVideoFilterSelectionCell {
            oldCell.setCellSelected(isSelected: false)
            UIView.animate(withDuration: 0.2) {
                oldCell.transform = .identity
            }
        }
        
        currentSelectedIndex = indexPath.row
        cell.setCellSelected(isSelected: true)
        
        UIView.animate(withDuration: 0.2) {
            cell.transform = .init(scaleX: 1.1, y: 1.1)
        }
        
        resultHandler?( .setFilterIntensity(self.currentFilterIntensity) )
        resultHandler?( .filterConfigSelected(filterList[indexPath.row]) )
        mainQueueResultHandler?( .showCancelBtn(true) )
        mainQueueResultHandler?( .showIntensitySlider(indexPath.row == 0 ? false : true ))
    }
    
}

