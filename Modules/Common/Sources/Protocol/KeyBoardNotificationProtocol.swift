//
//  KeyBoardNotificationProtocol.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/05/24.
//

import Foundation
import UIKit


@objc public protocol KeyboardNotificationProtocol {
    @objc func keyboardWillShow(notification: Notification)
    @objc func keyboardWillHide(notification: Notification)
    @objc func keyboardWillChangeFrame(notification: Notification)
}

public extension KeyboardNotificationProtocol {
    func registerKeyboardNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    func removeKeyboardNoti() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}
