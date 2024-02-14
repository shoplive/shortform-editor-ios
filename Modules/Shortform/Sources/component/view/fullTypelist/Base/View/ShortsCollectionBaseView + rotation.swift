//
//  ShortsCollectionBaseView + rotation.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/30/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon


extension ShortsCollectionBaseView {
    func onStartRotation(to size : CGSize){
        self.viewModel.isOnRotation = true
        self.viewModel.blockScrollViewDidScrollForRotation = true
//        guard let cell = (shortsListView.visibleCells as? [ShopLiveShortform.ShortsCell])?.first else { return }
        guard let cell = (shortsListView.visibleCells as? [ShortsCell])?.first else  { return }
        self.viewModel.capturedCurrentIndexPathForRotation = cell.getCellIndexPath()
        let isLandscape = UIScreen.isLandscape_SL
        cell.handleDeviceRotation(isLandscape: isLandscape)
    }
    
    func onChangingRotation(to size : CGSize){
        if let layout = shortsListView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = size
            layout.invalidateLayout()
        }
        
        guard let indexPath = viewModel.capturedCurrentIndexPathForRotation else { return }
        self.shortsListView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
    }
    
    func onFinishedRotation(on size : CGSize){
        self.viewModel.isOnRotation = false
        self.viewModel.blockScrollViewDidScrollForRotation = false
        self.viewModel.capturedCurrentIndexPathForRotation = nil
//        guard let cell = (shortsListView.visibleCells as? [ShopLiveShortform.ShortsCell])?.first else { return }
        guard let cell = (shortsListView.visibleCells as? [ShortsCell])?.first else  { return }
        
        cell.play(skipIfPaused: false)
    }
    
    func redrawPreviewDimLayer(){
        self.previewDim.layer.sublayers?.removeAll()
        self.previewDim.layer.addSublayer(self.previewDimLayer)
        self.previewDimLayer.frame = self.previewDim.frame
        
    }
}
