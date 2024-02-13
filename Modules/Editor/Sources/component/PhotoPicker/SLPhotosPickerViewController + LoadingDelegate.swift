//
//  SLPhotosPickerViewController + LoadingDelegate.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/6/23.
//

import Foundation
import UIKit
import ShopLiveSDKCommon



extension SLPhotosPickerViewController : SLLoadingAlertControllerDelegate {
    public func didCancelLoading() {
        //필터 관련 브랜치 머지하면서 구체화 될 예정 그전까지는 no - op으로 설정
    }
    
    public func didFinishLoading() {
        //필터 관련 브랜치 머지하면서 구체화 될 예정 그전까지는 no - op으로 설정
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
    
    public func finishLoading() {
        DispatchQueue.main.async { [weak self] in
            self?.loadingProgress.finishLoading()
            self?.loadingProgress.dismiss(animated: false)
        }
    }
    
    open func cancelLoading() {
        loadingProgress.cancelLoading = false
    }
}
