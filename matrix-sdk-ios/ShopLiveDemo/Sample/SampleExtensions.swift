//
//  SideMenuExtensions.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/12.
//

import Foundation
import UIKit
import Toast

extension UIButton {

    /// Default debounce delay for UIButton taps. Allows delay to be updated globally.
    static var debounceDelay: Double = 0.5

    /// Debounces button taps with the specified delay.
    func debounce(delay: Double = UIButton.debounceDelay) {
        isEnabled = false
        let deadline = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: deadline) { [weak self] in
            self?.isEnabled = true
        }
    }

}

extension UIApplication {
    static var topWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter({$0.activationState == .foregroundActive})
                .map({$0 as? UIWindowScene})
                .compactMap({$0})
                .first?.windows
                .filter({$0.isKeyWindow}).first
        } else {
            return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        }
    }
}

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

extension String {

    func localized(from: String = "shoplive", comment: String = "") -> String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: from)
    }

    func localized(with argument: CVarArg = [], from: String = "shoplive", comment: String = "") -> String {
        return String(format: self.localized(from: from, comment: comment), argument)
    }

    var cgfloatValue: CGFloat? {
        return CGFloat((self as NSString).floatValue)
    }

    var toJsonValue: String {
        "\"\(self)\""
    }

    var base64Decoded: String? {
       guard let decodedData = Data(base64Encoded: self) else { return nil }
       return String(data: decodedData, encoding: .utf8)
    }

    var base64Encoded: String? {
        let plainData = data(using: .utf8)
        return plainData?.base64EncodedString()
    }
}

extension Int {
    var toJsonValue: String {
        "\(self)"
    }
}

extension Array {

    subscript(safe range: Range<Index>) -> ArraySlice<Element> {
        return self[Swift.min(range.lowerBound, endIndex)..<Swift.min(range.upperBound, endIndex)]
    }
    
}

extension UITextField {
    func setPlaceholderColor(_ placeholderColor: UIColor) {
            attributedPlaceholder = NSAttributedString(
                string: placeholder ?? "",
                attributes: [
                    .foregroundColor: placeholderColor,
                    .font: font
                ].compactMapValues { $0 }
            )
        }
}

extension UIColor {

    convenience init(red: Int, green: Int, blue: Int, a: Int = 0xFF) {
        self.init(
            red: CGFloat(red) / 255.0,
            green: CGFloat(green) / 255.0,
            blue: CGFloat(blue) / 255.0,
            alpha: CGFloat(a) / 255.0
        )
    }

    convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
    }

    // let's suppose alpha is the first component (ARGB)
    convenience init(argb: Int) {
        self.init(
            red: (argb >> 16) & 0xFF,
            green: (argb >> 8) & 0xFF,
            blue: argb & 0xFF,
            a: (argb >> 24) & 0xFF
        )
    }

    convenience init(_ hex: String, alpha: CGFloat = 1.0) {
        var cString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if cString.hasPrefix("#") { cString.removeFirst() }

        if cString.count != 6 {
          self.init("ff0000") // return red color for wrong hex input
          return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                  green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                  blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                  alpha: alpha)
      }
}

extension UITextField {
    func addUnderLine() {
        self.borderStyle = .none
        let border = CALayer()
        border.frame = CGRect(x: 0, y: self.frame.size.height-1, width: self.frame.width, height: 1)
        border.backgroundColor = UIColor.black.cgColor
        self.layer.addSublayer(border)
        self.textColor = UIColor.black
    }
}

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.shopliveHideKeyboard))

        view.addGestureRecognizer(tap)
    }
}

extension Date {
    static var expiredTime: Int {
        Int(Date(timeIntervalSinceNow: 60 * 60 * 12).timeIntervalSince1970)
    }

    static var createdTime: Int {
        Int(Date().timeIntervalSince1970)
    }
}

extension String {
  func CGFloatValue() -> CGFloat? {
    guard let doubleValue = Double(self) else {
      return nil
    }

    return CGFloat(doubleValue)
  }
}

extension UserDefaults {
  func set(_ value: UIEdgeInsets, forKey key: String) {
    let rectDataArray = [value.top, value.left, value.bottom, value.right]
    set(rectDataArray, forKey: key)
  }

  func cgRect(forKey key: String) -> UIEdgeInsets? {
      guard let rectDataArray = array(forKey: key) as? [CGFloat] else { return nil }
      guard rectDataArray.count == 4 else { return nil }

      return UIEdgeInsets(top: rectDataArray[0], left: rectDataArray[1], bottom: rectDataArray[2], right: rectDataArray[3])
  }
}
