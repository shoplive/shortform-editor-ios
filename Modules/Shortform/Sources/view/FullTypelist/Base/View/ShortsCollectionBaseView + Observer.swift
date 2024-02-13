//
//  ShortsCollectionBaseView + Observer.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 8/29/23.
//

import Foundation
import UIKit
import ShopLiveSDKCommon


extension ShortsCollectionBaseView {
    func setupObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("closePreview"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("osShareSheet"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("setWindowSnapshot"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(_:)), name: NSNotification.Name("configUpdated"), object: nil)
        
        self.addObserver(self, forKeyPath: "frame", options: .new, context: nil)
    }
    
    func teardownObserver() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("closePreview"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("osShareSheet"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("setWindowSnapshot"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("configUpdated"), object: nil)
        NotificationCenter.default.removeObserver(self)
        self.safeRemoveObserver_SL(self, forKeyPath: "frame")
    }

    @objc func handleNotification(_ notification: Notification) {
        switch notification.name {
        case NSNotification.Name("closePreview"):
            guard viewModel.shortsMode == .preview else { return }
            ShopLiveShortform.close()
            break
        case NSNotification.Name("osShareSheet"):
            guard let url = notification.userInfo?["url"] as? String else {
                return
            }
            guard let parent = self.parentViewController_SL else { return }
            parent.showShareSheet_SL(url: url)
            break
        case NSNotification.Name("setWindowSnapshot"):
            guard let snapshot = notification.userInfo?["snapshot"] as? UIImage else {
                return
            }
            snapShotView.image = snapshot
            snapShotView.isHidden = false
            break
            
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
