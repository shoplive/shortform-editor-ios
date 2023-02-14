//
//  CustomReferrerAlertController.swift
//  ShopLiveSDK
//
//  Created by 김우현 on 2/14/23.
//

import Foundation
import UIKit

class CustomReferrerAlertController: CustomInputAlertController {
    
    private var placeHolder: String = "referrer.alert.placeholder".localized()
    
    override func setupAlert() {
        textInputField.text = DemoConfiguration.shared.customReferrer ?? ""
        textInputField.placeholder = self.placeHolder
        textInputField.setPlaceholderColor(.darkGray)
    }
    
    override func delete() {
        DemoConfiguration.shared.customReferrer = ""
    }
    
    override func save() {
        DemoConfiguration.shared.customReferrer = textInputField.text ?? ""
    }
}
