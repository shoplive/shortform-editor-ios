//
//  SLPhotosPickerReactor + LoadingDelegate.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 5/7/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit
import ShopliveSDKCommon

extension SLPhotosPickerReactor : SLLoadingAlertControllerDelegate {
    func didCancelLoading() {
        resultHandler?( .requestCancelLoading )
    }
    
    func didFinishLoading() {
        resultHandler?( .didFinishLoading )
    }
}
