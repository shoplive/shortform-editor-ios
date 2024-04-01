//
//  SLPasetInterceptTextView.swift
//  ShopLiveShortformEditorSDK
//
//  Created by sangmin han on 3/26/24.
//  Copyright © 2024 com.app. All rights reserved.
//

import Foundation
import UIKit


class SLPasteInterceptTextView : UITextView {
    
    var maxCharacterCount : Int = 50
    
    override func paste(_ sender: Any?) {
        let currentText = self.text ?? ""
        let currentTextCount = currentText.count
        
        if var paste = UIPasteboard.general.string {
            while paste.contains("\n\n") {
                paste = paste.replacingOccurrences(of: "\n\n", with: "\n")
            }
            paste = String(paste.prefix(max(0,maxCharacterCount - currentTextCount - 2)))
            UIPasteboard.general.string = paste
        }
        super.paste(sender)
       
    }
}
