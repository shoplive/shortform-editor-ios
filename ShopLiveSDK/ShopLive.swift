//
//  ShopLiveSDK.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/04.
//

import UIKit
import AVKit
import WebKit

@objc internal protocol ShopLiveComponent: AnyObject {
    @objc var viewController: ShopLiveViewController? { get }
    @objc var style: ShopLive.PresentationStyle { get }
    @objc var pipPosition: ShopLive.PipPosition { get set }
    @objc var pipScale: CGFloat { get set }
    @objc var indicatorColor: UIColor { get set }
    @objc var webViewConfiguration: WKWebViewConfiguration? { get set }
    @objc var delegate: ShopLiveSDKDelegate? { get set }

    @objc var authToken: String? { get set }
    @objc var user: ShopLiveUser? { get set }

    @objc func isSuccessCampaignJoin() -> Bool

    @objc func configure(with accessKey: String)
    @objc func preview(with campaignKey: String?, completion: @escaping () -> Void)
    @objc func play(with campaignKey: String?, _ parent: UIViewController?)
    @objc func startPictureInPicture(with position: ShopLive.PipPosition, scale: CGFloat)
    @objc func startPictureInPicture()
    @objc func stopPictureInPicture()

    @objc func setKeepAspectOnTabletPortrait(_ keep: Bool)

    @objc func setLoadingAnimation(images: [UIImage])

    @objc func setKeepPlayVideoOnHeadphoneUnplugged(_ keepPlay: Bool)
    @objc func isKeepPlayVideoOnHeadPhoneUnplugged() -> Bool
    @objc func setAutoResumeVideoOnCallEnded(_ autoResume: Bool)
    @objc func isAutoResumeVideoOnCallEnded() -> Bool

    @objc func reloadLive()
    @objc func onTerminated()

    @objc func hookNavigation(navigation: @escaping ((URL) -> Void))
    @objc func setShareScheme(_ scheme: String?, custom: (() -> Void)?)
    @objc func setChatViewFont(inputBoxFont: UIFont, sendButtonFont: UIFont)
    @objc func close()
    #if DEMO
    @objc var demo_phase: ShopLive.Phase { get set }
    #endif

}

enum ShopLiveCampaignStatus: String, CaseIterable {
    case ready = "READY"
    case onair = "ONAIR"
    case close = "CLOSE"
}

@objc public final class ShopLive: NSObject {
    static var shared: ShopLive = {
        return ShopLive()
    }()

    private var instance: ShopLiveComponent?
    override init() {
        super.init()
        instance = ShopLiveBase()
    }
}

extension ShopLive {
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
        var couponStatus: ShopLive.ResultStatus
        var alertType: ShopLive.ResultAlertType

        public init(couponId: String, success: Bool, message: String?, status: ShopLive.ResultStatus, alertType: ShopLive.ResultAlertType) {
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
        var couponStatus: ShopLive.ResultStatus
        var alertType: ShopLive.ResultAlertType

        public init(id: String, success: Bool, message: String?, status: ShopLive.ResultStatus, alertType: ShopLive.ResultAlertType) {
            self.id = id
            self.success = success
            self.message = message
            self.couponStatus = status
            self.alertType = alertType
        }
    }
    
    @objc public enum PipPosition: Int {
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case `default`

        public var name: String {
            switch self {
            case .default, .bottomRight:
                return "bottomRight"
            case .bottomLeft:
                return "bottomLeft"
            case .topLeft:
                return "topLeft"
            case .topRight:
                return "topRight"
            default:
                return "bottomRight"
            }
        }
    }

    @objc public enum PresentationStyle: Int {
        case unknown
        case fullScreen
        case pip

        var name: String {
            switch self {
            case .unknown:
                return "unknown"
            case .pip:
                return "pip"
            case .fullScreen:
                return "fullScreen"
            }
        }
    }

    @objc enum Phase: Int {
        #if DEMO
        case DEV
        #endif
        case STAGE
        case REAL

        public var name: String {
            switch self {
            #if DEMO
            case .DEV:
                return "DEV"
            #endif
            case .STAGE:
                return "STAGE"
            case .REAL:
                return "REAL"
            }
        }

        public init?(name: String) {
            switch name {
            #if DEMO
            case Phase.DEV.name:
                self = .DEV
            #endif
            case Phase.STAGE.name:
                self = .STAGE
            case Phase.REAL.name:
                self = .REAL
            default:
                return nil
            }

        }

    }
}

extension ShopLive: ShopLiveSDKInterface {
    public static func setPictureInPictureFloatingOffset(offset: UIEdgeInsets) {
        ShopLiveController.shared.pipFloatingOffset = offset
    }
    
    public static func setPictureInPicturePadding(padding: UIEdgeInsets) {
        ShopLiveController.shared.pipPadding = padding
    }

    public static func sendCommandMessage(payload: [String : Any]?) {
        guard let payload = payload else {
            return
        }

        ShopLiveController.webInstance?.sendEventToWeb(event: .sendCommandMessage, payload.toJson())
    }
    
    public static func setMuteWhenPlayStart(_ mute: Bool) {
        ShopLiveController.isMuted = mute
    }
    
    public static func setNextActionOnHandleNavigation(actionType: ActionType) {
        ShopLiveController.shared.nextActionTypeOnHandleNavigation = actionType
    }
    
    public static func getNextActionTypeOnHandleNavigation() -> ActionType {
        return ShopLiveController.shared.nextActionTypeOnHandleNavigation
    }
    
    public static func setEndpoint(_ url: String?) {
        ShopLiveDefines.endpoint = url
    }
    
    public static func isSuccessCampaignJoin() -> Bool {
        return shared.instance?.isSuccessCampaignJoin() ?? false
    }

    #if DEMO
    static var phase: ShopLive.Phase {
        set {
            shared.instance?.demo_phase = newValue
        }
        get {
            return shared.instance?.demo_phase ?? ShopLiveDefines.phase
        }
    }
    #endif

    public static func setKeepAspectOnTabletPortrait(_ keep: Bool = true) {
        shared.instance?.setKeepAspectOnTabletPortrait(keep)
    }

    public static var viewController: ShopLiveViewController? {
        shared.instance?.viewController
    }

    public static func close() {
        ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: "close api called"))
        shared.instance?.close()
    }

    public static func setChatViewFont(inputBoxFont: UIFont, sendButtonFont: UIFont) {
        shared.instance?.setChatViewFont(inputBoxFont: inputBoxFont, sendButtonFont: sendButtonFont)
    }

    public static func setShareScheme(_ scheme: String? = nil, custom: (() -> Void)?) {
        shared.instance?.setShareScheme(scheme, custom: custom)
    }

    public static func hookNavigation(navigation: @escaping ((URL) -> Void)) {
        shared.instance?.hookNavigation(navigation: navigation)
    }

    public static func onTerminated() {
        shared.instance?.onTerminated()
    }

    public static func setKeepPlayVideoOnHeadphoneUnplugged(_ keepPlay: Bool) {
        shared.instance?.setKeepPlayVideoOnHeadphoneUnplugged(keepPlay)
    }

    public static func isKeepPlayVideoOnHeadPhoneUnplugged() -> Bool {
        return shared.instance?.isKeepPlayVideoOnHeadPhoneUnplugged() ?? false
    }

    public static func setAutoResumeVideoOnCallEnded(_ autoResume: Bool) {
        shared.instance?.setAutoResumeVideoOnCallEnded(autoResume)
    }

    public static func isAutoResumeVideoOnCallEnded() -> Bool {
        return shared.instance?.isAutoResumeVideoOnCallEnded() ?? false
    }

    public static var sdkVersion: String {
        return ShopLiveDefines.sdkVersion
    }

    public static var user: ShopLiveUser? {
        get {
            shared.instance?.user
        }
        set {
            shared.instance?.user = newValue
        }
    }

    public static var style: PresentationStyle {
        return shared.instance?.style ?? .unknown
    }

    public static var pipPosition: PipPosition {
        get {
            shared.instance?.pipPosition ?? .default
        }
        set {
            shared.instance?.pipPosition = newValue
        }
    }

    public static var pipScale: CGFloat {
        get {
            shared.instance?.pipScale ?? 2/5
        }
        set {
            shared.instance?.pipScale = newValue
        }
    }

    public static var indicatorColor: UIColor  {
        get {
            shared.instance?.indicatorColor ?? .white
        }
        set {
            shared.instance?.indicatorColor = newValue
        }
    }


    public static var webViewConfiguration: WKWebViewConfiguration? {
        get {
            shared.instance?.webViewConfiguration
        }
        set {
            shared.instance?.webViewConfiguration = newValue
        }
    }

    public static var delegate: ShopLiveSDKDelegate? {
        get {
            shared.instance?.delegate
        }
        set {
            shared.instance?.delegate = newValue
        }
    }

    public static var authToken: String? {
        get {
            shared.instance?.authToken
        }
        set {
            shared.instance?.authToken = newValue
        }
    }

    public static func configure(with accessKey: String) {
        shared.instance?.configure(with: accessKey)
    }

    public static func preview(with campaignKey: String?, completion: @escaping () -> Void) {
        ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: "preview api called ck: \(campaignKey)"))
        ShopLiveController.shared.isPreview = true
        shared.instance?.preview(with: campaignKey, completion: completion)
    }

    public static func play(with campaignKey: String?, _ parent: UIViewController? = nil) {
        ShopLiveViewLogger.shared.addLog(log: .init(logType: .applog, log: "play api called ck: \(campaignKey)"))
        ShopLiveController.shared.isPreview = false
        shared.instance?.play(with: campaignKey, parent)
    }

    public static func startPictureInPicture(with position: PipPosition, scale: CGFloat) {
        shared.instance?.startPictureInPicture(with: position, scale: scale)
    }

    public static func startPictureInPicture() {
        shared.instance?.startPictureInPicture()
    }

    public static func stopPictureInPicture() {
        shared.instance?.stopPictureInPicture()
    }

    public static func setLoadingAnimation(images: [UIImage]) {
        shared.instance?.setLoadingAnimation(images: images)
    }

    public static func reloadLive() {
        shared.instance?.reloadLive()
    }
}

class ShopLiveSettings {
    var indicatorColor: UIColor = .white
    var isCustomIndicator: Bool {
        return customIndicatorImages.count > 0
    }
    var customIndicatorImages: [UIImage] = []

    func setLoadingAnimation(images: [UIImage]) {
        customIndicatorImages.removeAll()
        customIndicatorImages.append(contentsOf: images)
    }

    func clear() {
        indicatorColor = .white
        customIndicatorImages.removeAll()
    }
}
