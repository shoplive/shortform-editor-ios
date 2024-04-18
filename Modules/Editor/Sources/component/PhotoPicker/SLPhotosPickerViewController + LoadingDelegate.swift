//
//  SLPhotosPickerViewController + LoadingDelegate.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/6/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon



extension SLPhotosPickerViewController : SLLoadingAlertControllerDelegate {
    public func didCancelLoading() {
        loadingProgress.cancelLoading = false
    }
    
    public func didFinishLoading() {
        
    }
    
    func startLoading() {
        guard !self.isSelectedFromCamera else { return }
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loadingProgress.modalPresentationStyle = .overFullScreen
            self.loadingProgress.setLoadingText("Loading...")
            
            guard !self.loadingProgress.isBeingPresented else { return }
            self.navigationController?.present(self.loadingProgress, animated: false)
        }
    }
    
    func finishLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.loadingProgress.finishLoading()
        }
    }
}
