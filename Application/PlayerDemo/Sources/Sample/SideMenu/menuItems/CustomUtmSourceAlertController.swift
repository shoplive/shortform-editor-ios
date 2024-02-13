//
//  CustomAdIdAlertController.swift
//  ShopLiveSDK
//
//  Created by 김우현 on 3/28/23.
//

import Foundation
import UIKit

class CustomUtmSourceAlertController: CustomInputAlertController {
    
    private var placeHolder: String = "utmSource.alert.placeholder".localized()
    
    override func setupAlert() {
        textInputField.text = DemoConfiguration.shared.utmSource ?? ""
        textInputField.placeholder = self.placeHolder
        textInputField.setPlaceholderColor(.darkGray)
    }
    
    override func delete() {
        DemoConfiguration.shared.utmSource = ""
    }
    
    override func save() {
        DemoConfiguration.shared.utmSource = textInputField.text ?? ""
    }
}
