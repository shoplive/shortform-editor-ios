//
//  ShopLiveSDKInterface.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/03/05.
//

import Foundation
import WebKit
import UIKit

@objc public enum ResultStatus: Int, CaseIterable {
    case SHOW
    case HIDE
    case KEEP

    public var name: String {
        switch self {
        case .SHOW:
            return "SHOW"
        case .HIDE:
            return "HIDE"
        case .KEEP:
            return "KEEP"
        }
    }
}

@objc public enum ResultAlertType: Int, CaseIterable {
    case ALERT
    case TOAST

    public var name: String {
        switch self {
        case .ALERT:
            return "ALERT"
        case .TOAST:
            return "TOAST"
        }
    }
}

@objc public class CouponResult: NSObject {
    var success: Bool
    var coupon: String = ""
    var message: String?
    var couponStatus: ResultStatus
    var alertType: ResultAlertType

    public init(couponId: String, success: Bool, message: String?, status: ResultStatus, alertType: ResultAlertType) {
        self.coupon = couponId
        self.success = success
        self.message = message
        self.couponStatus = status
        self.alertType = alertType
    }
}

@objc public class CustomActionResult: NSObject {
    var success: Bool
    var id: String = ""
    var message: String?
    var couponStatus: ResultStatus
    var alertType: ResultAlertType

    public init(id: String, success: Bool, message: String?, status: ResultStatus, alertType: ResultAlertType) {
        self.id = id
        self.success = success
        self.message = message
        self.couponStatus = status
        self.alertType = alertType
    }
}

@objc public protocol ShopLiveSDKDelegate: AnyObject {
    @objc func handleNavigation(with url: URL)
    @objc optional func handleDownloadCouponResult(with couponId: String, completion: @escaping (CouponResult) -> Void)
    @available(*, deprecated, message: "use handleDownloadCouponResult instead")
    @objc optional func handleDownloadCoupon(with couponId: String, completion: @escaping () -> Void)
    @objc optional func handleCustomActionResult(with id: String, type: String, payload: Any?, completion: @escaping (CustomActionResult) -> Void)
    @available(*, deprecated, message: "use handleCustomActionResult instead")
    @objc optional func handleCustomAction(with id: String, type: String, payload: Any?, completion: @escaping () -> Void)

    @objc func handleChangeCampaignStatus(status: String)
    @objc func handleError(code: String, message: String)
    @objc func handleCampaignInfo(campaignInfo: [String : Any])
    @objc func handleCommand(_ command: String, with payload: Any?)
    @objc func onSetUserName(_ payload: [String : Any])
    @objc func handleReceivedCommand(_ command: String, with payload: Any?)
}

@objc public class ShopLiveViewController: UIViewController {

}

@objc protocol ShopLiveSDKInterface: AnyObject {
    @objc static var sdkVersion: String { get }
#if DEMO
    @objc static var phase: ShopLive.Phase { get set }
#endif
    @objc static var viewController: ShopLiveViewController? { get }
    @objc static var style: ShopLive.PresentationStyle { get }
    @objc static var pipPosition: ShopLive.PipPosition { get set }
    @objc static var pipScale: CGFloat { get set }
    @objc static var indicatorColor: UIColor { get set }
    @objc static var webViewConfiguration: WKWebViewConfiguration? { get set }
    @objc static var delegate: ShopLiveSDKDelegate? { get set }

    
    @objc static var authToken: String? { get set }
    @objc static var user: ShopLiveUser? { get set }

    @objc static func isSuccessCampaignJoin() -> Bool
    
    @objc static func configure(with accessKey: String)
    @objc static func preview(with campaignKey: String?, completion: @escaping () -> Void)
    @objc static func play(with campaignKey: String?, _ parent: UIViewController?)
    @objc static func startPictureInPicture(with position: ShopLive.PipPosition, scale: CGFloat)
    @objc static func startPictureInPicture()
    @objc static func stopPictureInPicture()

    @objc static func setLoadingAnimation(images: [UIImage])

    @objc static func setKeepAspectOnTabletPortrait(_ keep: Bool)

    @objc static func setKeepPlayVideoOnHeadphoneUnplugged(_ keepPlay: Bool)
    @objc static func isKeepPlayVideoOnHeadPhoneUnplugged() -> Bool
    @objc static func setAutoResumeVideoOnCallEnded(_ autoResume: Bool)
    @objc static func isAutoResumeVideoOnCallEnded() -> Bool
    
    @objc static func reloadLive()
    @objc static func onTerminated()

    @objc static func hookNavigation(navigation: @escaping  ((URL) -> Void))
    @objc static func setShareScheme(_ scheme: String?, custom: (() -> Void)?)
    @objc static func setChatViewFont(inputBoxFont: UIFont, sendButtonFont: UIFont)
    @objc static func close()
}
