//
//  CustomAdIdAlertController.swift
//  ShopLiveSDK
//
//  Created by 김우현 on 3/28/23.
//

import Foundation
import UIKit

class CustomUtmSourceAlertController: CustomInputAlertController {
    
    enum UtmType {
        case source
        case content
        case campaign
        case medium
        case anonId
        case adId
    }
    
    private var placeHolder: String = "utm.alert.placeholder".localized()
    
    var utmType : UtmType = .source {
        didSet {
            switch utmType {
            case .source:
                textInputField.text = DemoConfiguration.shared.utmSource ?? ""
            case .content:
                textInputField.text = DemoConfiguration.shared.utmContent ?? ""
            case .campaign:
                textInputField.text = DemoConfiguration.shared.utmCampaign ?? ""
            case .medium:
                textInputField.text = DemoConfiguration.shared.utmMedium ?? ""
            case .anonId:
                textInputField.text = DemoConfiguration.shared.anonId ?? ""
            case .adId:
                textInputField.text = DemoConfiguration.shared.adId ?? ""
            }
        }
    }
    
    override func setupAlert() {
        switch utmType {
        case .source:
            textInputField.text = DemoConfiguration.shared.utmSource ?? ""
        case .content:
            textInputField.text = DemoConfiguration.shared.utmContent ?? ""
        case .campaign:
            textInputField.text = DemoConfiguration.shared.utmCampaign ?? ""
        case .medium:
            textInputField.text = DemoConfiguration.shared.utmMedium ?? ""
        case .anonId:
            textInputField.text = DemoConfiguration.shared.anonId ?? ""
        case .adId:
            textInputField.text = DemoConfiguration.shared.adId ?? ""
        }
        textInputField.placeholder = self.placeHolder
        textInputField.setPlaceholderColor(.darkGray)
    }
    
    override func delete() {
        switch utmType {
        case .source:
            DemoConfiguration.shared.utmSource = ""
        case .content:
            DemoConfiguration.shared.utmContent = ""
        case .campaign:
            DemoConfiguration.shared.utmCampaign = ""
        case .medium:
            DemoConfiguration.shared.utmMedium = ""
        case .anonId:
            DemoConfiguration.shared.anonId = ""
        case .adId:
            DemoConfiguration.shared.anonId = ""
        }
       
    }
    
    override func save() {
        switch utmType {
        case .source:
            DemoConfiguration.shared.utmSource =  textInputField.text ?? ""
        case .content:
            DemoConfiguration.shared.utmContent =  textInputField.text ?? ""
        case .campaign:
            DemoConfiguration.shared.utmCampaign =  textInputField.text ?? ""
        case .medium:
            DemoConfiguration.shared.utmMedium =  textInputField.text ?? ""
        case .anonId:
            DemoConfiguration.shared.anonId =  textInputField.text ?? ""
        case .adId:
            DemoConfiguration.shared.adId = textInputField.text ?? ""
        }
    }
}
