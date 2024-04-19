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
    
    static var url: String {
        "https://www.shoplive.show/v1/sdk.html"
    }

    static let shopliveData = "shoplivedata"

    static let webInterface: String = "ShopLiveAppInterface"
    static let osVersion = UIDevice.current.systemVersion
    
    static let defVideoRatio: CGSize = .init(width: 9, height: 16)
    
    static var deviceIdentifier: String {
        return UIDevice.deviceIdentifier_sl
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
    func handleReceivedCommand(_ command: String, with payload: [String : Any]?)
    func changeOrientation(to: ShopLiveDefines.ShopLiveOrientaion)
    func updatePictureInPicture()
    func finishRotation()
    func resetPictureInPicture()
    
    func log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any])
    func requestHandleShare(data : ShopLivePlayerShareData)
    func handleShopLivePlayerCampaign(campaign : ShopLivePlayerCampaign)
    func handleShopLivePlayerBrand(brand : ShopLivePlayerBrand)
}

protocol OverlayWebViewDelegate: AnyObject {
    func didUpdatePlaybackSpeed(speed : Float)
    func didUpdateVideo(with url: URL)
    func reloadVideo()
    func didUpdatePoster(with url: URL)
    func replay(with size: CGSize)
    func setVideoCurrentTime(to: CMTime)
    func didTouchBlockView()

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
    
    func handleReceivedCommand(_ command: String, with payload: [String : Any]?)
    
    func updatePlayerFrame(centerCrop: Bool, playerFrame: CGRect, immediately: Bool, targetWindowStyle : ShopLiveWindowStyle?)
    func updateOrientation(toLandscape: Bool)
    func log(name: String, feature: ShopLiveLog.Feature, campaign: String, payload: [String: Any])
    func didFailToLoadWebViewWithNetworkUnreachable()
    func requestReloadWebView()
    func webViewDidFinishedLoading()
    func requestHideOrShowLoadingFromWebView(isHidden : Bool)
    func requestNetworkCapabilityOnSystemInit()
    func requestHandleShare(data : ShopLivePlayerShareData)
}

extension Notification.Name {
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
