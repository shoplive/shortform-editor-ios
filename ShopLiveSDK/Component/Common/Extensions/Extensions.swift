//
//  Extensions.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/07/06.
//

import Foundation
import UIKit
import AVKit

extension UIViewController
{
    @objc public func shopliveHideKeyboard()
    {
        view.endEditing(true)
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }

        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController
            { return topViewController(base: selected) }
        }

        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    class func appVersion() -> String {
            return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        }

        class func appBuild() -> String {
            return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        }

        class func versionBuild() -> String {
            let version = appVersion(), build = appBuild()

            return version == build ? "v\(version)" : "v\(version)(\(build))"
        }
}

extension NSObject {
  func safeRemoveObserver(_ observer: NSObject, forKeyPath keyPath: String) {
    switch self.observationInfo {
    case .some:
      self.removeObserver(observer, forKeyPath: keyPath)
    default:
        ShopLiveLogger.debugLog("observer does not exist")
    }
  }
}

extension Array {
    subscript (safe index: Int) -> Element? {
        // iOS 9 or later
        return indices ~= index ? self[index] : nil
        // iOS 8 or earlier
        // return startIndex <= index && index < endIndex ? self[index] : nil
        // return 0 <= index && index < self.count ? self[index] : nil
    }
}

extension UIDevice {
    static var isIpad: Bool {
        self.current.userInterfaceIdiom == .pad
    }
}

extension UIButton {
    func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        UIGraphicsBeginImageContext(CGSize(width: 1.0, height: 1.0))
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setFillColor(color.cgColor)
        context.fill(CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0))

        let backgroundImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        self.setBackgroundImage(backgroundImage, for: state)
    }
}

extension UIView {
    func addSubviews(_ views: UIView...) {
        views.forEach { view in
            self.addSubview(view)
        }
    }
    
    func fitToSuperView() {
        guard let superview = self.superview else { return }
        self.translatesAutoresizingMaskIntoConstraints = false
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
        superview.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-0-[subview]-0-|", options: .directionLeadingToTrailing, metrics: nil, views: ["subview": self]))
    }
}

extension AVPlayer.TimeControlStatus {
    var name: String {
        switch self {
        case .playing:
            return "playing"
        case .waitingToPlayAtSpecifiedRate:
            return "waitingToPlayAtSpecifiedRate"
        case .paused:
            return "paused"
        @unknown default:
            return ""
        }
    }
}
extension String {

    var urlEncodedString: String? {
        let customAllowedSet =  NSCharacterSet(charactersIn:"=\"#%/<>?@\\^`{|}+").inverted
        return self.addingPercentEncoding(withAllowedCharacters: customAllowedSet)
    }

    var urlEncodedStringRFC3986: String? {
        let unreserved = "-._~"
        let allowed = NSMutableCharacterSet.alphanumeric()
        allowed.addCharacters(in: unreserved)
        return addingPercentEncoding(withAllowedCharacters: allowed as CharacterSet)
    }
    
    func versionCompare(_ otherVersion: String) -> ComparisonResult {
        return self.compare(otherVersion, options: .numeric)
    }

    func fotmattedString() -> String {
        guard let doubleSelf = Double(self) else {
            return ""
        }

        return doubleSelf.formattedString(by: "yyyy.MM.dd (E) HH:mm.ss")
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }

    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}

extension Double {
    func formattedString(by format: String) -> String {
        var fromDate: Double = self
        if self.numberOfDigit > 10 {
            fromDate = Double(self / pow(10, Double(self.numberOfDigit - 10)))
        }

        let date = Date(timeIntervalSince1970: fromDate)

        let dmf = DateFormatter()
        dmf.timeZone = .current
        dmf.locale = Locale(identifier: Locale.current.identifier)
        dmf.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        dmf.dateFormat = format
        return dmf.string(from: date)
    }

    func elapsedTimeString() -> String {
        let now = Date()
        return elapsedTimeString(with: now)
    }

    var numberOfDigit: Int {
        guard let str: String = .init("\(Int(self))") else { return 0 }
        return str.count
    }

    func elapsedTimeString(with date: Date) -> String {
        var fromDate: Double = self

        if self.numberOfDigit > 10 {
            fromDate = Double(self / pow(10, Double(self.numberOfDigit - 10)))
        }

        let dateFrom = Date(timeIntervalSince1970: fromDate)
        let dateTo = date

        /*
         ShopLiveLogger.printLog("from \(dateTo.timeIntervalSince1970))", "")

         ShopLiveLogger.printLog("from \(dateFrom.formattedString(by: "yyyy.MM.dd (E) HH:mm"))", "")

         ShopLiveLogger.printLog("to \(dateTo.formattedString(by: "yyyy.MM.dd (E) HH:mm"))", "")

         */

        guard dateFrom.timeIntervalSince1970 < dateTo.timeIntervalSince1970 else {
            return ""
        }

        let difference = NSCalendar.current.dateComponents([.hour, .minute, .second], from: dateFrom, to: dateTo)

        let elapsedTime: String = ((difference.hour ?? 0 > 0) ? String(format: "%02d:", difference.hour!) : "") + ((difference.minute ?? 0 > 0) ? String(format: "%02d:", difference.minute!) : "00:") + ((difference.second ?? 0 > 0) ? String(format: "%02d", difference.second!) : "00")

        return elapsedTime
    }
}

extension String {
    func textWithDownArrow() -> NSAttributedString {
        let downArrow = UIImage(named: "down_arrow")

        let attrText: NSMutableAttributedString = .init(string: "\(self) ")
        guard let downArrowImage = downArrow else {
            return attrText
        }

        attrText.append(.init(attachment: downArrowImage.toNSTextAttachment(yPos: 3)))
        return attrText
    }
}


 extension UIImage {
     func toNSTextAttachment(_ width: CGFloat? = nil, _ height: CGFloat? = nil, _ yPos: CGFloat = -8) -> NSTextAttachment {
         let imageAttachment = NSTextAttachment()
         imageAttachment.bounds = CGRect(x: 0, y: yPos, width: width ?? self.size.width, height: height ?? self.size.height)
         imageAttachment.image = self
         return imageAttachment
     }

     func toNSTextAttachment(yPos: CGFloat = -8) -> NSTextAttachment {
         let imageAttachment = NSTextAttachment()
         imageAttachment.bounds = CGRect(x: 0, y: yPos, width:  self.size.width, height: self.size.height)
         imageAttachment.image = self
         return imageAttachment
     }
 }

internal extension CouponResult {
    func toJson() -> String? {
        let couponJson = NSMutableDictionary()
        couponJson.setValue(self.success, forKey: "success")
        couponJson.setValue(self.coupon, forKey: "coupon")
        couponJson.setValue(self.message ?? "", forKey: "message")
        couponJson.setValue(self.couponStatus.name, forKey: "couponStatus")
        couponJson.setValue(self.alertType.name, forKey: "alertType")
        return couponJson.toJson()
    }
}

internal extension CustomActionResult {
    func toJson() -> String? {
        let couponJson = NSMutableDictionary()
        couponJson.setValue(self.success, forKey: "success")
        couponJson.setValue(self.id, forKey: "id")
        couponJson.setValue(self.message ?? "", forKey: "message")
        couponJson.setValue(self.couponStatus.name, forKey: "couponStatus")
        couponJson.setValue(self.alertType.name, forKey: "alertType")
        return couponJson.toJson()
    }
}

internal extension ShopLive.CouponResult {
    func toJson() -> String? {
        let couponJson = NSMutableDictionary()
        couponJson.setValue(self.success, forKey: "success")
        couponJson.setValue(self.coupon, forKey: "coupon")
        couponJson.setValue(self.message ?? "", forKey: "message")
        couponJson.setValue(self.couponStatus.name, forKey: "couponStatus")
        couponJson.setValue(self.alertType.name, forKey: "alertType")
        return couponJson.toJson()
    }
}

internal extension ShopLive.CustomActionResult {
    func toJson() -> String? {
        let couponJson = NSMutableDictionary()
        couponJson.setValue(self.success, forKey: "success")
        couponJson.setValue(self.id, forKey: "id")
        couponJson.setValue(self.message ?? "", forKey: "message")
        couponJson.setValue(self.couponStatus.name, forKey: "couponStatus")
        couponJson.setValue(self.alertType.name, forKey: "alertType")
        return couponJson.toJson()
    }
}

extension UIScreen {
    static var isLandscape: Bool {
        let size = UIScreen.main.bounds.size
        return size.width > size.height
    }
}

extension CALayer {
    func fitToSuperView(superview: UIView) {
        self.frame = superview.frame
    }
}

extension NSMutableDictionary {
    func toJson() -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [])
        if let jsonString = String(data: jsonData!, encoding: .utf8){
            return jsonString
        }else{
            return nil
        }
    }
}

extension Dictionary {
    func toJson() -> String? {
        let jsonData = try? JSONSerialization.data(withJSONObject: self, options: [])
        if let jsonString = String(data: jsonData!, encoding: .utf8){
            return jsonString
        }else{
            return nil
        }
    }

    var jsonData: Data? {
            return try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
        }

    func toJSONString() -> String? {
        if let jsonData = jsonData {
            let jsonString = String(data: jsonData, encoding: .utf8)
            return jsonString
        }

        return nil
    }
}

extension UIFont {
    func findAvailableFont() -> UIFont {
        var fontSize: CGFloat = 30
        var currentLineHeight: CGFloat = self.lineHeight
        
        guard currentLineHeight > 20 else {
            return self
        }
        
        repeat {
            currentLineHeight = self.withSize(fontSize).lineHeight
            fontSize -= 1
        } while 20 < currentLineHeight && fontSize >= 0
        
        return fontSize == 0 ? .systemFont(ofSize: 14, weight: .regular) : self.withSize(fontSize)
    }
    
    func lineHeightMultiple(_ lineHeight: CGFloat = 20) -> CGFloat {
        return lineHeight / self.lineHeight
    }
}

extension UITextView {
    func numberOfLines() -> Int {
        let size = CGSize(width: frame.width, height: .infinity)
        let estimatedSize = sizeThatFits(size)
        
        return Int(estimatedSize.height / (self.font!.lineHeight))
    }
}
