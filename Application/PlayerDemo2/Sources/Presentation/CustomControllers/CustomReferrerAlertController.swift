//
//  CustomReferrerAlertController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
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
