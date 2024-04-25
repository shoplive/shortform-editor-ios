//
//  ShopLiveSDKInterface.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/03/05.
//

import Foundation
import WebKit
import UIKit
import ShopliveSDKCommon

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

@objc public enum ShopLiveResultStatus: Int, CaseIterable {
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

@objc public enum ShopLiveResultAlertType: Int, CaseIterable {
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

@objc public class ShopLiveCouponResult: NSObject {
    var success: Bool
    var coupon: String = ""
    var message: String?
    var couponStatus: ShopLiveResultStatus
    var alertType: ShopLiveResultAlertType

    public init(couponId: String, success: Bool, message: String?, status: ShopLiveResultStatus, alertType: ShopLiveResultAlertType) {
        self.coupon = couponId
        self.success = success
        self.message = message
        self.couponStatus = status
        self.alertType = alertType
    }
}

@objc public class ShopLiveCustomActionResult: NSObject {
    var success: Bool
    var id: String = ""
    var message: String?
    var couponStatus: ShopLiveResultStatus
    var alertType: ShopLiveResultAlertType

    public init(id: String, success: Bool, message: String?, status: ShopLiveResultStatus, alertType: ShopLiveResultAlertType) {
        self.id = id
        self.success = success
        self.message = message
        self.couponStatus = status
        self.alertType = alertType
    }
}

@objc public class ShopLiveLog: NSObject {
    @objc public enum Feature: Int, CaseIterable {
        case CLICK, SHOW, ACTION
        
        public var name: String {
            switch self {
            case .CLICK:
                return "click"
            case .ACTION:
                return "action"
            case .SHOW:
                return "show"
            }
        }
        
        static func featureFrom(type: String) -> Feature? {
            return Feature.allCases.filter({$0.name == type}).first
        }
    }
    
    public var name: String
    public var campaign: String
    public var feature: Feature
    @available(*, deprecated, message: "use payload: [String : Any] instead")
    public var parameter: [String : String] = [:]
    public var payload: [String: Any] = [:]
    
    public init(name: String, feature: Feature, campaign: String, parameter: [String : String]) {
        self.name = name
        self.feature = feature
        self.campaign = campaign
        self.parameter = parameter
    }
    
    public init(name: String, feature: Feature, campaign: String, payload: [String : Any]) {
        self.name = name
        self.feature = feature
        self.campaign = campaign
        self.payload = payload
    }
}

@objc public enum ActionType: Int {
    case PIP
    case KEEP
    case CLOSE

    public var name: String {
        switch self {
        case .PIP:
            return "PIP"
        case .KEEP:
            return "KEEP"
        case .CLOSE:
            return "CLOSE"
        }
    }
}

@objc public protocol ShopLiveSDKDelegate: AnyObject {
    
    @objc func handleNavigation(with url: URL)
    
    
    @available(*, deprecated, message: "use handleDownloadCoupon(with couponId: String, result: @escaping (ShopLiveCouponResult) -> Void) instead")
    @objc optional func handleDownloadCouponResult(with couponId: String, completion: @escaping (CouponResult) -> Void)
    @objc optional func handleDownloadCoupon(with couponId: String, result: @escaping (ShopLiveCouponResult) -> Void)
    @available(*, deprecated, message: "use handleDownloadCoupon(with couponId: String, result: @escaping (ShopLiveCouponResult) -> Void) instead")
    @objc optional func handleDownloadCoupon(with couponId: String, completion: @escaping () -> Void)
    @available(*, deprecated, message: "use handleCustomAction(with id: String, type: String, payload: Any?, result: @escaping (ShopLiveCustomActionResult) -> Void) instead")
    @objc optional func handleCustomActionResult(with id: String, type: String, payload: Any?, completion: @escaping (CustomActionResult) -> Void)
    @available(*, deprecated, message: "use handleCustomAction(with id: String, type: String, payload: Any?, result: @escaping (ShopLiveCustomActionResult) -> Void) instead")
    @objc optional func handleCustomAction(with id: String, type: String, payload: Any?, completion: @escaping () -> Void)
    @objc optional func handleCustomAction(with id: String, type: String, payload: Any?, result: @escaping (ShopLiveCustomActionResult) -> Void)

    @objc optional func handleChangeCampaignStatus(status: String)
    @objc optional func handleChangedPlayerStatus(status: String)
    @objc optional func handleError(code: String, message: String)
    @objc optional func handleCampaignInfo(campaignInfo: [String : Any])
    
    @objc optional func onSetUserName(_ payload: [String : Any])
    
    @objc optional func handleCommand(_ command: String, with payload: Any?)
    
    @available(*, deprecated, message: "use handleReceivedCommand(_ command : String , data : [String : Any]?) instead")
    @objc optional func handleReceivedCommand(_ command: String, with payload: Any?)
    //TODO: - HASSAN
    @objc optional func handleReceivedCommand(_ command : String , data : [String : Any]?)
    
    
    @objc optional func playerPanGesture(state: UIGestureRecognizer.State, position: CGPoint)
    
    @available(*, deprecated, message: "use log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any]) instead")
    @objc optional func log(name: String, feature: ShopLiveLog.Feature, campaign: String, parameter: [String: String])
    @objc optional func log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any])
    
}

public typealias ShopLiveViewController = SLViewController

@objc protocol ShopLiveSDKInterface: AnyObject {
    @objc static var sdkVersion: String { get }
    @objc static var playerWindow: ShopliveWindow? { get }
    
    @available(iOS, deprecated, message: "Use setInAppPipConfiguration(config : ShopLiveInAppPipConfiguration) instead")
    @objc static var fixedPipWidth: NSNumber? { get set }
    @objc static func mute()
    @objc static func unmute()
    @objc static var playerMode: ShopLive.PlayerMode { get }
    @objc static var orientationMode: ShopLive.VideoOrientation { get }
    
    @objc static var viewController: ShopLiveViewController? { get }
    @objc static var style: ShopLive.PresentationStyle { get }
    
    @available(iOS, deprecated, message: "Use setInAppPipConfiguration(config : ShopLiveInAppPipConfiguration) instead")
    @objc static var pipPosition: ShopLive.PipPosition { get set }
    
    @available(iOS, deprecated, message: "Use pipMaxSize in setInAppPipConfiguration(config : ShopLiveInAppPipConfiguration) instead")
    @objc static var pipScale: CGFloat { get set }
    
    
    @objc static var indicatorColor: UIColor { get set }
    @objc static var webViewConfiguration: WKWebViewConfiguration? { get set }
    @objc static var delegate: ShopLiveSDKDelegate? { get set }

    @objc static func isSuccessCampaignJoin() -> Bool
    
    @objc static func preview(data : ShopLivePlayerData,completion : (() -> Void)?)
    
    @available(iOS, deprecated, message: "Use preview(data : ShopLivePlayerData) instead")
    @objc static func preview(with campaignKey: String?, referrer: String?, completion:  (() -> Void)?)
    
    @objc static func play(data : ShopLivePlayerData)
    @available(iOS, deprecated, message: "Use play(data : ShopLivePlayerData) instead")
    @objc static func play(with campaignKey: String?, keepWindowStateOnPlayExecuted: Bool, referrer: String?)
    @objc static func startPictureInPicture(with position: ShopLive.PipPosition, scale: CGFloat)
    @objc static func startPictureInPicture()
    @objc static func stopPictureInPicture()
    @objc static func setEnabledPictureInPictureMode(isEnabled : Bool)
    @objc static func setEnabledOSPictureInPictureMode(isEnabled : Bool)

    @objc static func setLoadingAnimation(images: [UIImage])

    @objc static func setKeepAspectOnTabletPortrait(_ keep: Bool)

    @objc static func setKeepPlayVideoOnHeadphoneUnplugged(_ keepPlay: Bool, isMute: Bool)
    @objc static func isKeepPlayVideoOnHeadPhoneUnplugged() -> Bool
    @objc static func setAutoResumeVideoOnCallEnded(_ autoResume: Bool)
    @objc static func isAutoResumeVideoOnCallEnded() -> Bool
    
    @objc static func reloadLive()
    @objc static func onTerminated()

    @objc static func hookNavigation(navigation: @escaping  ((URL) -> Void))
    @objc static func setShareScheme(_ scheme: String?, shareDelegate: ShopLivePlayerShareDelegate?)
    @objc static func setChatViewFont(inputBoxFont: UIFont?, sendButtonFont: UIFont?)
    @objc static func close(actionType : ShopLiveViewHiddenActionType)
    
    @objc static func setEndpoint(_ url: String?)
    
    @objc static func setNextActionOnHandleNavigation(actionType: ActionType)
    @objc static func getNextActionTypeOnHandleNavigation() -> ActionType

    @objc static func sendCommandMessage(command: String, payload: [String:Any]?)
    @objc static func setMuteWhenPlayStart(_ mute: Bool)

    @objc static func setPictureInPicturePadding(padding: UIEdgeInsets) -> Bool
    @objc static func setPictureInPictureFloatingOffset(offset: UIEdgeInsets) -> Bool
    
    @objc static func setUsingLocalStorage(_ use: Bool)
    @objc static func setAppVersion(_ appVersion: String)
    
    @objc static func setKeepWindowStyleOnReturnFromOsPip(_ keep: Bool)
    @objc static func isKeepWindowStyleOnReturnFromOsPip() -> Bool
    
    @objc static func awakePlayer()
    
    @objc static func setMixWithOthers(isMixAudio: Bool)
    
    @available(iOS, deprecated, message: "Use setInAppPipConfiguration(config : ShopLiveInAppPipConfiguration) instead")
    @objc static func useCloseButton(_ use: Bool)
    
    @available(iOS, deprecated, message: "Enable AppTrackingTransparency instead")
    @objc static func setAdId(adId: String?)
    @objc static func addParameter(key: String, value: String)
    @objc static func removeParameter(key: String)
    
    @available(iOS, deprecated, message: "Use setInAppPipConfiguration(config : ShopLiveInAppPipConfiguration) instead")
    @objc static func setEnabledPipSwipeOut(_ enabled: Bool)
    
    //MARK: - will be deprecated in v2
    //실제 값이 저장되는 곳은 ShopLiveCommon에 저장됨
//    @available(*, deprecated, message: "Will be deprecated in v2, use ShopLiveCommon.setUserJWT(userJWT: String?) instead")
    @objc static var authToken : String? { get set }
//    @available(*, deprecated, message: "use ShopLiveCommon.setUser(user: ShopLiveCommonUser?) instead")
    @objc static var user : ShopLiveCommonUser? { get set }
//    @available(*, deprecated, message: "use ShopLiveCommon.setAccessKey(accessKey: String) instead")
    @objc static func configure(with accessKey : String)
    @objc static func setInAppPipConfiguration(config : ShopLiveInAppPipConfiguration)
    
    @objc static func setUtmSource(utmSource : String?)
    @objc static func setUtmCampaign(utmCampaign : String?)
    @objc static func setUtmMedium(utmMedium : String?)
    @objc static func setUtmContent(utmContent : String?)
    
    @objc static func getUtmSource() -> String?
    @objc static func getUtmCampaign() -> String?
    @objc static func getUtmMedium() -> String?
    @objc static func getUtmContent() -> String?
    
    
    @objc static func setVisibleStatusBar(isVisible : Bool)
    @objc static func isVisibleStatusBar() -> Bool
    
    @objc static func addSubViewToPreview(subView : UIView)
    @objc static func getPreviewSize(inAppPipConfiguration : ShopLiveInAppPipConfiguration, videoRatio : CGSize) -> CGSize
}
