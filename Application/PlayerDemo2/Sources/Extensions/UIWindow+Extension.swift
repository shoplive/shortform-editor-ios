//
//  UIWindow+Extension.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import UIKit
import Toast

extension UIWindow {
    static func showToast(message: String) {
        guard let view = UIApplication.topWindow else { return }
        var toastStyle = ToastStyle()
        toastStyle.titleAlignment = .center
        toastStyle.messageAlignment = .center
        view.makeToast(message, duration: 2,style: toastStyle)
    }

    static func showToast(message: String, curView: UIView? = nil) {
        guard let view = UIApplication.topWindow ?? curView else { return }
        var toastStyle = ToastStyle()
        toastStyle.titleAlignment = .center
        toastStyle.messageAlignment = .center
        view.makeToast(message, duration: 2,style: toastStyle)
    }
}
