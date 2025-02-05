//
//  CustomAppVersionInputAlertController.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/20/25.
//  Copyright © 2025 com.app. All rights reserved.
//
import Foundation
import UIKit

class CustomAppVersionInputAlertController: CustomInputAlertController {

    private var placeHolder: String = "appversion.alert.placeholder".localized()

    override func setupAlert() {
//        textInputField.text = DemoConfiguration.shared.customAppVersion ?? ""
        textInputField.placeholder = self.placeHolder
        textInputField.setPlaceholderColor(.darkGray)
    }

    override func delete() {
//        DemoConfiguration.shared.customAppVersion = ""
    }
    
    override func save() {
//        DemoConfiguration.shared.customAppVersion = textInputField.text ?? ""
    }

}

