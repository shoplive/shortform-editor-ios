//
//  UINavigationController+extension.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation
import UIKit

public extension UINavigationController {
    open override var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
