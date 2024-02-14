//
//  UIWindow+extension.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation
import UIKit

public extension UIWindow {
    static var mainWindowFrame_SL: UIWindow {
        UIWindow(frame: UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.frame ?? UIScreen.main.bounds)
    }
}
