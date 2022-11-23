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
    @objc var playerWindow: UIWindow? { get }
    @objc var fixedPipWidth: NSNumber? { get set }
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
    @objc func play(with campaignKey: String?)
    @objc func startPictureInPicture(with position: ShopLive.PipPosition, scale: CGFloat)
    @objc func startPictureInPicture()
    @objc func stopPictureInPicture()

    @objc func setKeepAspectOnTabletPortrait(_ keep: Bool)

    @objc func setLoadingAnimation(images: [UIImage])

    @objc func setKeepPlayVideoOnHeadphoneUnplugged(_ keepPlay: Bool, isMute: Bool)
    @objc func isKeepPlayVideoOnHeadPhoneUnplugged() -> Bool
    @objc func setAutoResumeVideoOnCallEnded(_ autoResume: Bool)
    @objc func isAutoResumeVideoOnCallEnded() -> Bool

    @objc func reloadLive()
    @objc func onTerminated()

    @objc func hookNavigation(navigation: @escaping ((URL) -> Void))
    @objc func setShareScheme(_ scheme: String?, custom: (() -> Void)?)
    @objc func setChatViewFont(inputBoxFont: UIFont?, sendButtonFont: UIFont?)
    @objc func close()
    
    @objc func awakePlayer()
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

enum ShopLiveWindowChangeCommand {
    case none
    case switchToInAppPip
    case switchToFullScreen
}

extension ShopLive {
    @objc public enum PlayerMode: Int {
        case play
        case preview
        case none
        
        public var name: String {
            switch self {
            case .play:
                return "play"
            case .preview:
                return "preview"
            case .none:
                return "none"
            }
        }
    }
    
    @objc public enum VideoOrientation: Int {
        case portrait
        case landscape
        case unknown
        
        public var name: String {
            switch self {
            case .portrait:
                return "portrait"
            case .landscape:
                return "landscape"
            case .unknown:
                return "unknown"
            }
        }
    }
}

extension ShopLive {
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
    /*
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
     */
}

extension ShopLive: ShopLiveSDKInterface {
    public static func awakePlayer() {
        shared.instance?.awakePlayer()
    }
    
    public static func setKeepWindowStyleOnReturnFromOsPip(_ keep: Bool = false) {
        ShopLiveConfiguration.UI.keepWindowStyleOnReturnFromOsPip = keep
    }
    
    public static func isKeepWindowStyleOnReturnFromOsPip() -> Bool {
        ShopLiveConfiguration.UI.keepWindowStyleOnReturnFromOsPip
    }
    
    public static func setAppVersion(_ appVersion: String) {
        ShopLiveConfiguration.AppPreference.appVersion = appVersion
    }
    
    public static func setUsingLocalStorage(_ use: Bool) {
        ShopLiveConfiguration.Data.useLocalStorage = use
    }
    
    public static func setPictureInPictureFloatingOffset(offset: UIEdgeInsets) {
        ShopLiveConfiguration.UI.pipFloatingOffset = offset
    }
    
    public static func setPictureInPicturePadding(padding: UIEdgeInsets) {
        ShopLiveConfiguration.UI.pipPadding = padding
    }

    public static func sendCommandMessage(command: String, payload: [String : Any]?) {
        guard let payload = payload else {
            return
        }

        var message: [String : Any] = [:]

        message["command"] = command
        message["payload"] = payload

        ShopLiveController.webInstance?.sendEventToWeb(event: .sendCommandMessage, message.toJson())
    }
    
    public static func setMuteWhenPlayStart(_ mute: Bool) {
        ShopLiveConfiguration.SoundPolicy.isMuted = mute
    }
    
    public static func setNextActionOnHandleNavigation(actionType: ActionType) {
        ShopLiveConfiguration.UI.nextActionTypeOnHandleNavigation = actionType
    }
    
    public static func getNextActionTypeOnHandleNavigation() -> ActionType {
        return ShopLiveConfiguration.UI.nextActionTypeOnHandleNavigation
    }
    
    public static func setEndpoint(_ url: String?) {
        ShopLiveConfiguration.AppPreference.endpoint = url
    }
    
    public static func isSuccessCampaignJoin() -> Bool {
        return shared.instance?.isSuccessCampaignJoin() ?? false
    }

    public static func setKeepAspectOnTabletPortrait(_ keep: Bool = true) {
        shared.instance?.setKeepAspectOnTabletPortrait(keep)
    }

    public static var viewController: ShopLiveViewController? {
        shared.instance?.viewController
    }

    public static func close() {
        ShopLiveController.shared.execusedClose = true
        shared.instance?.close()
    }

    public static func setChatViewFont(inputBoxFont: UIFont?, sendButtonFont: UIFont?) {
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

    public static func setKeepPlayVideoOnHeadphoneUnplugged(_ keepPlay: Bool, isMute: Bool = false) {
        shared.instance?.setKeepPlayVideoOnHeadphoneUnplugged(keepPlay, isMute: isMute)
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
    
    public static var playerMode: ShopLive.PlayerMode {
        ShopLiveController.shared.playerMode
    }
    
    public static var playerWindow: UIWindow? {
        return shared.instance?.playerWindow
    }
    
    public static var fixedPipWidth: NSNumber? {
        get {
            return shared.instance?.fixedPipWidth
        }
        set {
            shared.instance?.fixedPipWidth = newValue
        }
    }
    
    public static func mute() {
        ShopLiveController.shared.setSoundMute(isMuted: true)
    }
    
    public static func unmute() {
        ShopLiveController.shared.setSoundMute(isMuted: false)
    }
    
    public static var orientationMode: ShopLive.VideoOrientation {
        ShopLiveController.shared.supportOrientation
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
            return ShopLiveController.shared.lastPipPosition
        }
        set {
            ShopLiveController.shared.lastPipPosition = newValue
        }
    }

    public static var pipScale: CGFloat {
        get {
            shared.instance?.pipScale ?? ShopLiveController.shared.lastPipScale
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
        shared.instance?.preview(with: campaignKey, completion: completion)
    }

    public static func play(with campaignKey: String?, keepWindowStateOnPlayExecuted: Bool = false) {
        ShopLiveConfiguration.UI.keepWindowStateOnPlayExecuted = keepWindowStateOnPlayExecuted
        shared.instance?.play(with: campaignKey)
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
