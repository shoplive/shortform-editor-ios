//
//  ShopLiveShortformUploadDelegate.swift
//  ShopLiveShortformUploadSDK
//
//  Created by sangmin han on 2023/07/27.
//

import Foundation
import ShopliveSDKCommon


public protocol ShopLiveShortformEditorDelegate : AnyObject {
    func onShortformUploadError(error : ShopLiveCommonError)
    //TODO: -  성공적으로 올렸을때 이벤트 전달
    func onShortformEditorSuccess()
    //TODO: - mediaPicker 사라졌는지 이벤트 전달
    func onShortformEditorMediaPickerDismiss()
}
