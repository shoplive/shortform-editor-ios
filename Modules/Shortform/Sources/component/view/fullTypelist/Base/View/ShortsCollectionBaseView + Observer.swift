//
//  ShortsCollectionBaseView + Observer.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/29/23.
//

import Foundation
import UIKit
import ShopliveSDKCommon


extension ShortsCollectionBaseView {
    func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("configUpdated"), object: nil)
        
    }
    
    func teardownObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("configUpdated"), object: nil)
        NotificationCenter.default.removeObserver(self)
    }

    @objc func handleNotification(_ notification: Notification) {
        switch notification.name {
        case NSNotification.Name("configUpdated"):
            DispatchQueue.main.async {
                self.viewModel.setShortsConfiguration()
            }
            break
        default:
            break
        }
    }
    
}

