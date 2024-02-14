//
//  SLBaseViewController.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/06/01.
//

import Foundation
import UIKit

open class SLBaseViewController : UIViewController {
    
    public var useOrientationLock : Bool = false
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if useOrientationLock {
            ShopLiveAppDelegate.shared.swizzleSupportedInterfaceOrientation()
        }
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if useOrientationLock {
            ShopLiveAppDelegate.shared.deswizzleSupportedInterfaceOrientation()
        }
    }
}
