//
//  ShopLiveSDK.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/02/04.
//

import UIKit
import AVKit
import WebKit
import ShopliveSDKCommon

@objc internal protocol ShopLiveComponent: AnyObject {
    @objc var playerWindow: ShopliveWindow? { get }
    @objc var fixedPipWidth: NSNumber? { get set }
    @objc var viewController: ShopLiveViewController? { get }
    @objc var style: ShopLive.PresentationStyle { get }
    @objc var pipScale: CGFloat { get set }
    
    @objc var indicatorColor: UIColor { get set }
    @objc var webViewConfiguration: WKWebViewConfiguration? { get set }
    @objc var delegate: ShopLiveSDKDelegate? { get set }
    
    @objc func isSuccessCampaignJoin() -> Bool

    @objc func preview(with campaignKey: String?, referrer: String?, campaignHandler : ((ShopLivePlayerCampaign) ->())?, brandHandler : ((ShopLivePlayerBrand) -> ())?,  completion: (() -> Void)?)
    @objc func play(with campaignKey: String?, referrer: String?, campaignHandler : ((ShopLivePlayerCampaign) ->())?, brandHandler : ((ShopLivePlayerBrand) -> ())?)
    @objc func startPictureInPicture(with position: ShopLive.PipPosition, scale: CGFloat)
    @objc func startPictureInPicture()
    @objc func stopPictureInPicture()
    @objc func setEnabledPictureInPictureMode(isEnabled : Bool)
    @objc func setEnabledOSPictureInPictureMode(isEnabled : Bool)
    @objc func setKeepAspectOnTabletPortrait(_ keep: Bool)

    @objc func setLoadingAnimation(images: [UIImage])

    @objc func setKeepPlayVideoOnHeadphoneUnplugged(_ keepPlay: Bool, isMute: Bool)
    @objc func isKeepPlayVideoOnHeadPhoneUnplugged() -> Bool
    @objc func setAutoResumeVideoOnCallEnded(_ autoResume: Bool)
    @objc func isAutoResumeVideoOnCallEnded() -> Bool

    @objc func reloadLive()
    @objc func onTerminated()

    @objc func hookNavigation(navigation: @escaping ((URL) -> Void))
    @objc func setShareScheme(_ scheme: String?, shareDelegate : ShopLivePlayerShareDelegate?)
    @objc func setChatViewFont(inputBoxFont: UIFont?, sendButtonFont: UIFont?)
    @objc func close(actionType : ShopLiveViewHiddenActionType)

    
    @objc func awakePlayer()
    
    @objc func setMixWithOthers(isMixAudio: Bool)
    
    @objc func setInAppPipConfiguration(config : ShopLiveInAppPipConfiguration)
    
    
    @objc func setStatusBarVisibility(isVisible : Bool)
    @objc func getStatusBarVisibility() -> Bool
    
    
    @objc func addSubViewToPreview(subView : UIView)
    @objc func getPreviewSize(inAppPipConfiguration : ShopLiveInAppPipConfiguration, videoRatio : CGSize) -> CGSize
    @objc func setResizeMode(mode : ShopLiveResizeMode)
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
}

extension ShopLive: ShopLiveSDKInterface {
    
   
    @available(iOS, deprecated, message: "Will be deprecated soon Use setInAppPipConfiguration(config : ShopLiveInAppPipConfiguration) instead")
    public static func setEnabledPipSwipeOut(_ enabled: Bool) {
        ShopLiveConfiguration.UI.enablePipSwipeOut = enabled
    }
    
    public static func removeParameter(key: String) {
        ShopLiveConfiguration.Data.customParameters.removeValue(forKey: key)
    }
    
    public static func addParameter(key: String, value: String) {
        ShopLiveConfiguration.Data.customParameters[key] = value
    }
    
    @available(iOS, deprecated, message: "Will be deprecated soon please Enable AppTrackingTransparency instead")
    public static func setAdId(adId: String?) {
        ShopLiveCommon.setAdId(adId: adId)
    }
    
    public static func setMixWithOthers(isMixAudio: Bool) {
        shared.instance?.setMixWithOthers(isMixAudio: isMixAudio)
    }
    
    @available(iOS, deprecated, message: "Will be deprecated soon Use setInAppPipConfiguration(config : ShopLiveInAppPipConfiguration) instead")
    public static func useCloseButton(_ use: Bool) {
        ShopLiveConfiguration.UI.closeButton = use
    }
    
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
        ShopLiveConfiguration.AppPreference.appVersion = appVersion.isEmpty ? nil : appVersion
    }
    
    public static func setUsingLocalStorage(_ use: Bool) {
        ShopLiveConfiguration.Data.useLocalStorage = use
    }
    
    public static func setPictureInPictureFloatingOffset(offset: UIEdgeInsets) -> Bool {
        let padding = ShopLiveConfiguration.UI.pipPadding
        let xRangeOverlapped = (offset.left + padding.left) >= (UIScreen.main.bounds.width - offset.right - padding.right)
        let yRangeOverlapped = (offset.top + padding.top) >= (UIScreen.main.bounds.height - offset.bottom - padding.bottom)
        
        
        if xRangeOverlapped || yRangeOverlapped {
            return false
        }
        ShopLiveConfiguration.UI.pipFloatingOffset = offset
        
        return true
    }
    
    public static func setPictureInPicturePadding(padding: UIEdgeInsets) -> Bool {
        let offset = ShopLiveConfiguration.UI.pipFloatingOffset
        let xRangeOverlapped = (offset.left + padding.left) >= (UIScreen.main.bounds.width - offset.right - padding.right)
        let yRangeOverlapped = (offset.top + padding.top) >= (UIScreen.main.bounds.height - offset.bottom - padding.bottom)
        
        
        if xRangeOverlapped || yRangeOverlapped {
            return false
        }
        ShopLiveConfiguration.UI.pipPadding = padding
        
        return true
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
        ShopLiveConfiguration.SoundPolicy.isMutedWhenStart = mute
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
    
    @available(iOS, deprecated, message: "deprecated on 1.5.10")
    public static func setKeepAspectOnTabletPortrait(_ keep: Bool = true) {
        shared.instance?.setKeepAspectOnTabletPortrait(keep)
    }

    public static var viewController: ShopLiveViewController? {
        shared.instance?.viewController
    }

    public static func close(actionType : ShopLiveViewHiddenActionType = .onClose) {
        ShopLiveController.shared.execusedClose = true
        shared.instance?.close(actionType: actionType)
    }

    public static func setChatViewFont(inputBoxFont: UIFont?, sendButtonFont: UIFont?) {
        shared.instance?.setChatViewFont(inputBoxFont: inputBoxFont, sendButtonFont: sendButtonFont)
    }
    
    public static func setShareScheme(_ scheme: String? = nil , shareDelegate : ShopLivePlayerShareDelegate?) {
        shared.instance?.setShareScheme(scheme, shareDelegate: shareDelegate)
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
        return ShopLiveCommon.playerSdkVersion
    }
    
    public static var playerMode: ShopLive.PlayerMode {
        ShopLiveController.shared.playerMode
    }
    
    public static var playerWindow: ShopliveWindow? {
        return shared.instance?.playerWindow
    }
    
    @available(iOS, deprecated, message: "Will be deprecated soon use setInAppPipConfiguration(config : ShopLiveInAppPipConfiguration) instead")
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
    
    public static var style: PresentationStyle {
        return shared.instance?.style ?? .unknown
    }

    @available(iOS, deprecated, message: "Will be deprecated soon use setInAppPipConfiguration(config : ShopLiveInAppPipConfiguration) instead")
    public static var pipPosition: PipPosition {
        get {
            return ShopLiveController.shared.initialPipPosition
        }
        set {
            ShopLiveController.shared.initialPipPosition = newValue
        }
    }
    @available(iOS, deprecated, message: "Will be deprecated soon use pipMaxSize in setInAppPipConfiguration(config : ShopLiveInAppPipConfiguration) instead")
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

    public static func preview(data: ShopLivePlayerData,completion : (() -> Void)? = nil) {
        if let data = data as? ShopLivePreviewData {
            ShopLiveConfiguration.SoundPolicy.previewSoundEnabled = !(data.isMuted ?? false)
        }
        ShopLiveConfiguration.SoundPolicy.isEnabledVolumeKeyInPreview = data.isEnabledVolumeKey
        shared.instance?.preview(with: data.campaignKey, referrer: data.referrer, campaignHandler: data.campaignHandler, brandHandler: data.brandHandler, completion: completion)
        
    }
    
    @available(iOS, deprecated, message: "Use preview(data : ShopLivePlayerData) instead")
    public static func preview(with campaignKey: String?, referrer: String? = nil, completion: (() -> Void)? = nil) {
        shared.instance?.preview(with: campaignKey, referrer: referrer, campaignHandler: nil, brandHandler: nil, completion: completion)
    }

    public static func play(data : ShopLivePlayerData) {
        ShopLiveConfiguration.UI.keepWindowStateOnPlayExecuted = data.keepWindowStateOnPlayExecuted
        ShopLiveConfiguration.SoundPolicy.isEnabledVolumeKeyInPreview = data.isEnabledVolumeKey
        shared.instance?.play(with: data.campaignKey, referrer: data.referrer, campaignHandler: data.campaignHandler, brandHandler: data.brandHandler)
    }
    
    @available(iOS, deprecated, message: "Use play(data : ShopLivePlayerData) instead")
    public static func play(with campaignKey: String?, keepWindowStateOnPlayExecuted: Bool = false, referrer: String? = nil) {
        ShopLiveConfiguration.UI.keepWindowStateOnPlayExecuted = keepWindowStateOnPlayExecuted
        shared.instance?.play(with: campaignKey, referrer: referrer,campaignHandler: nil, brandHandler: nil)
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
    
    public static func setEnabledPictureInPictureMode(isEnabled : Bool){
        shared.instance?.setEnabledPictureInPictureMode(isEnabled: isEnabled)
    }
    
    public static func setEnabledOSPictureInPictureMode(isEnabled: Bool) {
        shared.instance?.setEnabledOSPictureInPictureMode(isEnabled: isEnabled)
    }
    
    //MARK: - will be deprecated in v2
    public static var authToken: String? {
        set {
            ShopLiveCommon.setAuthToken(authToken: newValue)
        }
        get {
            ShopLiveCommon.getAuthToken()
        }
    }
    
    public static var user: ShopLiveCommonUser? {
        set {
            ShopLiveCommon.setUser(user: newValue, accessKey: ShopLiveCommon.getAccessKey())
        }
        get {
            ShopLiveCommon.getUser()
        }
    }
    
    public static func configure(with accessKey: String) {
        ShopLiveCommon.setAccessKey(accessKey: accessKey)
    }
    // --end
    
    public static func setInAppPipConfiguration(config: ShopLiveInAppPipConfiguration) {
        shared.instance?.setInAppPipConfiguration(config: config)
    }
    
    public static func setUtmSource(utmSource: String?) {
        ShopLiveCommon.setUtmSource(utmSource: utmSource)
    }
    
    public static func setUtmCampaign(utmCampaign: String?) {
        ShopLiveCommon.setUtmCampaign(utmCampaign: utmCampaign)
    }
    
    public static func setUtmMedium(utmMedium: String?) {
        ShopLiveCommon.setUtmMedium(utmMedium: utmMedium)
    }
    
    public static func setUtmContent(utmContent: String?) {
        ShopLiveCommon.setUtmContent(utmContent: utmContent)
    }
    
    public static func getUtmSource() -> String? {
        return ShopLiveCommon.getUtmSource()
    }
    
    public static func getUtmCampaign() -> String? {
        return ShopLiveCommon.getUtmCampaign()
    }
    
    public static func getUtmMedium() -> String? {
        return ShopLiveCommon.getUtmMedium()
    }
    
    public static func getUtmContent() -> String? {
        return ShopLiveCommon.getUtmContent()
    }
    
    public static func setVisibleStatusBar(isVisible : Bool) {
        shared.instance?.setStatusBarVisibility(isVisible: isVisible)
    }
    
    public  static func isVisibleStatusBar() -> Bool {
        return shared.instance?.getStatusBarVisibility() ?? true
    }
    
    public static func addSubViewToPreview(subView: UIView) {
        shared.instance?.addSubViewToPreview(subView: subView)
    }
    
    public static func getPreviewSize(inAppPipConfiguration: ShopLiveInAppPipConfiguration, videoRatio: CGSize) -> CGSize {
        guard let instance = shared.instance else {
            return .zero
        }
        return instance.getPreviewSize(inAppPipConfiguration: inAppPipConfiguration, videoRatio: videoRatio)
    }
    
    public static func setResizeMode(mode: ShopLiveResizeMode) {
        shared.instance?.setResizeMode(mode: mode)
    }
}
