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
import AVKit


public typealias ShopLiveViewController = SLViewController

@objc protocol ShopLiveSDKInterface: AnyObject {
    @objc static var sdkVersion: String { get }
    @objc static var playerWindow: ShopliveWindow? { get }
    
    @available(iOS, deprecated, message: "Use setInAppPipConfiguration(config: ShopLiveInAppPipConfiguration) instead")
    @objc static var fixedPipWidth: NSNumber? { get set }
    @objc static func mute()
    @objc static func unmute()
    @objc static var playerMode: ShopLive.PlayerMode { get }
    @objc static var orientationMode: ShopLive.VideoOrientation { get }
    
    @objc static var viewController: ShopLiveViewController? { get }
    @objc static var style: ShopLive.PresentationStyle { get }
    
    @available(iOS, deprecated, message: "Use setInAppPipConfiguration(config: ShopLiveInAppPipConfiguration) instead")
    @objc static var pipPosition: ShopLive.PipPosition { get set }
    
    @available(iOS, deprecated, message: "Use pipMaxSize in setInAppPipConfiguration(config: ShopLiveInAppPipConfiguration) instead")
    @objc static var pipScale: CGFloat { get set }
    
    
    @objc static var indicatorColor: UIColor { get set }
    @objc static var webViewConfiguration: WKWebViewConfiguration? { get set }
    @objc static var delegate: ShopLiveSDKDelegate? { get set }

    @objc static func isSuccessCampaignJoin() -> Bool
    
    @objc static func preview(data: ShopLivePlayerData,completion: (() -> Void)?)
    
    @available(iOS, deprecated, message: "Use preview(data: ShopLivePlayerData) instead")
    @objc static func preview(with campaignKey: String?, referrer: String?, completion:  (() -> Void)?)
    
    @objc static func play(data: ShopLivePlayerData)
    @available(iOS, deprecated, message: "Use play(data: ShopLivePlayerData) instead")
    @objc static func play(with campaignKey: String?, keepWindowStateOnPlayExecuted: Bool, referrer: String?)
    @objc static func startPictureInPicture(with position: ShopLive.PipPosition, scale: CGFloat)
    @objc static func startPictureInPicture()
    @objc static func stopPictureInPicture()
    @objc static func setEnabledPictureInPictureMode(isEnabled: Bool)
    @objc static func setEnabledOSPictureInPictureMode(isEnabled: Bool)

    @objc static func setLoadingAnimation(images: [UIImage])
    
    @available(iOS, deprecated, message: "deprecated on 1.5.10")
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
    @objc static func close(actionType: ShopLiveViewHiddenActionType)
    
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
    @objc static func setAudioSessionCategory(category: AVAudioSession.Category)
    
    @available(iOS, deprecated, message: "Use setInAppPipConfiguration(config: ShopLiveInAppPipConfiguration) instead")
    @objc static func useCloseButton(_ use: Bool)
    
    @available(iOS, deprecated, message: "Enable AppTrackingTransparency instead")
    @objc static func setAdId(adId: String?)
    @objc static func addParameter(key: String, value: String)
    @objc static func removeParameter(key: String)
    
    @available(iOS, deprecated, message: "Use setInAppPipConfiguration(config: ShopLiveInAppPipConfiguration) instead")
    @objc static func setEnabledPipSwipeOut(_ enabled: Bool)
    
    //MARK: - will be deprecated in v2
    //실제 값이 저장되는 곳은 ShopLiveCommon에 저장됨
//    @available(*, deprecated, message: "Will be deprecated in v2, use ShopLiveCommon.setUserJWT(userJWT: String?) instead")
    @objc static var authToken: String? { get set }
//    @available(*, deprecated, message: "use ShopLiveCommon.setUser(user: ShopLiveCommonUser?) instead")
    @objc static var user: ShopLiveCommonUser? { get set }
//    @available(*, deprecated, message: "use ShopLiveCommon.setAccessKey(accessKey: String) instead")
    @objc static func configure(with accessKey: String)
    @objc static func setInAppPipConfiguration(config: ShopLiveInAppPipConfiguration)
    
    @objc static func setUtmSource(utmSource: String?)
    @objc static func setUtmCampaign(utmCampaign: String?)
    @objc static func setUtmMedium(utmMedium: String?)
    @objc static func setUtmContent(utmContent: String?)
    
    @objc static func getUtmSource() -> String?
    @objc static func getUtmCampaign() -> String?
    @objc static func getUtmMedium() -> String?
    @objc static func getUtmContent() -> String?
    
    
    @objc static func setVisibleStatusBar(isVisible: Bool)
    @objc static func isVisibleStatusBar() -> Bool
    
    @objc static func addSubViewToPreview(subView: UIView)
    @objc static func getPreviewSize(inAppPipConfiguration: ShopLiveInAppPipConfiguration, videoRatio: CGSize) -> CGSize
    
    
    @objc static func setResizeMode(mode: ShopLiveResizeMode)
    @objc static func forceStartWithPortraitMode(_ isForced: Bool)
}
