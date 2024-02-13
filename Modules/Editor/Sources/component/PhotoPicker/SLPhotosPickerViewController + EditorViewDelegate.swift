//
//  SLPhotosPickerViewController + EditorViewDelegate.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 12/6/23.
//

import Foundation
import UIKit


extension SLPhotosPickerViewController : SLVideoEditorViewControllerDelegate {
    func cancelConvertVideo() {
        let bundle = Bundle(for: type(of: self))
        self.showToast(message: "toast.cancel.encoding.title".localizedString(bundle: bundle), duration: .long)
    }
}
