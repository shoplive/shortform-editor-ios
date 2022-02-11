//
//  Commons.swift
//  ShopLiveSDK
//
//  Created by ShopLive on 2021/05/19.
//

import Foundation
import UIKit
import CoreMedia
//import CoreTelephony

@objc internal final class ShopLiveDefines: NSObject {
    static let sdkVersion: String = "1.2.2"
    static var phase: ShopLive.Phase = .REAL
    static var url: String {
        switch phase {
        #if DEMO
        case .DEV:
            return "https://dev.shoplive.show/v1/sdk.html"
        #endif
        case .STAGE:
            return "https://stg.shoplive.show/v1/sdk.html"
        default:
            return "https://www.shoplive.show/v1/sdk.html"
        }
    }
    
    static var endpoint: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "shopliveEndpoint")
        }
        get  {
            UserDefaults.standard.string(forKey: "shopliveEndpoint")
        }
    }
    
    static var landingUrl: String {
        endpoint ?? url
    }

    static let webInterface: String = "ShopLiveAppInterface"
    static let osVersion = UIDevice.current.systemVersion

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

//    static func deviceModelName() -> String {
//        let model = UIDevice.current.model
//
//        switch model {
//        case "iPhone":
//            return self.iPhoneModel()
//        case "iPad":
//            return self.iPadModel()
//        case "iPad mini" :
//            return self.iPadMiniModel()
//        default:
//            return "Unknown Model : \(model)"
//        }
//    }


    static func mccMnc() -> String? {
        /*
#if os(iOS)
        let networkInfo =  CTTelephonyNetworkInfo()
        if #available(iOS 12.0, *) {
            guard let info = networkInfo.serviceSubscriberCellularProviders,
                  let dict = networkInfo.serviceCurrentRadioAccessTechnology,
                  let key = dict.keys.first,
                  let carrier = info[key],
                  let mcc = carrier.mobileCountryCode,
                  let mnc = carrier.mobileNetworkCode
            else { return nil }
            return mcc + "-" + mnc
        } else {
            guard let carrier = networkInfo.subscriberCellularProvider,
                  let mcc = carrier.mobileCountryCode,
                  let mnc = carrier.mobileNetworkCode
            else { return nil }
            return mcc + "_" + mnc
        }
#else
        return nil
#endif
         */
        return nil
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
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
}
