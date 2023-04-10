//
//  Commons.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/05/19.
//

import Foundation
import UIKit
import CoreMedia

@objc internal final class ShopLiveDefines: NSObject {
    static let sdkVersion: String = "1.3.4"
    
    /*
    static var phase: ShopLive.Phase = .REAL {
        didSet {
            ShopLiveConfiguration.AppPreference.landingUrl = url
        }
    }
     */
    
    static var url: String {
//        switch phase {
//        #if DEMO
//        case .DEV:
//            return "https://dev.shoplive.show/v1/sdk.html"
//        #endif
//        case .STAGE:
//            return "https://stg.shoplive.show/v1/sdk.html"
//        default:
//            return "https://www.shoplive.show/v1/sdk.html"
//        }
        "https://www.shoplive.show/v1/sdk.html"
    }

    static let shopliveData = "shoplivedata"

    static let webInterface: String = "ShopLiveAppInterface"
    static let osVersion = UIDevice.current.systemVersion
    
    static let defVideoRatio: CGSize = .init(width: 9, height: 16)
    
    static var deviceIdentifier: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        return identifier
    }
    
    enum ShopLiveOrientaion {
        case portrait
        case landscape
    }
}

protocol LiveStreamViewControllerDelegate: AnyObject {
    func didTouchPipButton()
    func didTouchCustomAction(id: String, type: String, payload: Any?)
    func didTouchCloseButton()
    func didTouchNavigation(with url: URL)
    func didTouchCoupon(with couponId: String)
    func handleCommand(_ command: String, with payload: Any?)
    func replay(with size: CGSize)
    func campaignInfo(campaignInfo: [String : Any])
    func didChangeCampaignStatus(status: String)
    func onError(code: String, message: String)
    func onSetUserName(_ payload: [String : Any])
    func handleReceivedCommand(_ command: String, with payload: Any?)
    func changeOrientation(to: ShopLiveDefines.ShopLiveOrientaion)
    func updatePictureInPicture()
    func finishRotation()
    func resetPictureInPicture()
    @available(*, deprecated, message: "use log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any]) instead")
    func log(name: String, feature: ShopLiveLog.Feature, campaign: String, parameter: [String : String])
    func log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any])
}

protocol OverlayWebViewDelegate: AnyObject {
    func didUpdateVideo(with url: URL)
    func reloadVideo()
    func didUpdatePoster(with url: URL)
    func replay(with size: CGSize)
    func setVideoCurrentTime(to: CMTime)
    func didTouchBlockView()

    func didTouchShareButton(with url: URL?)
    func didTouchCustomAction(id: String, type: String, payload: Any?)
    func didTouchPlayButton()
    func didTouchPauseButton()
    func didTouchMuteButton(with isMuted: Bool)
    func didTouchPipButton()
    func didTouchCloseButton()
    func didTouchNavigation(with url: URL)
    func didTouchCoupon(with couponId: String)
    func didChangeCampaignStatus(status: String)
    func onError(code: String, message: String)
    func handleCommand(_ command: String, with payload: Any?)
    func onSetUserName(_ payload: [String : Any])
    func handleReceivedCommand(_ command: String, with payload: Any?)
    func updatePlayerFrame(centerCrop: Bool, playerFrame: CGRect, immediately: Bool)
    func updateOrientation(orientation: UIDeviceOrientation)
    func updateOrientation(toLandscape: Bool)
    @available(*, deprecated, message: "use log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any]) instead")
    func log(name: String, feature: ShopLiveLog.Feature, campaign: String, parameter: [String : String])
    func log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any])
}

extension Notification.Name {
    /// Notification for when a timebase changed rate
    static let TimebaseEffectiveRateChangedNotification = Notification.Name(rawValue: kCMTimebaseNotification_EffectiveRateChanged as String)
}


@objc protocol KeyboardNotificationProtocol {
    @objc func keyboardWillShow(notification: Notification)
    @objc func keyboardWillHide(notification: Notification)
    @objc func keyboardWillChangeFrame(notification: Notification)
}

extension KeyboardNotificationProtocol {

    func registerKeyboardNoti() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillChangeFrame(notification:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }

    func removeKeyboardNoti() {
        NotificationCenter.default.safeRemoveObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.safeRemoveObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.safeRemoveObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}
