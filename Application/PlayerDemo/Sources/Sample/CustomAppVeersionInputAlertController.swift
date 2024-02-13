//
//  CustomAppVersionInputAlertController.swift
//  ShopLiveSDK
//
//  Created by Vincent on 12/8/22.
//

import Foundation
import UIKit


class CustomAppVersionInputAlertController: CustomInputAlertController {

    private var placeHolder: String = "appversion.alert.placeholder".localized()

    override func setupAlert() {
        textInputField.text = DemoConfiguration.shared.customAppVersion ?? ""
        textInputField.placeholder = self.placeHolder
        textInputField.setPlaceholderColor(.darkGray)
    }

    override func delete() {
        DemoConfiguration.shared.customAppVersion = ""
    }
    
    override func save() {
        DemoConfiguration.shared.customAppVersion = textInputField.text ?? ""
    }

}
