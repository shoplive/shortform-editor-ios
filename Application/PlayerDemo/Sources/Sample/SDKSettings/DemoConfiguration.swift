//
//  DemoConfiguration.swift
//  ShopLiveDemo
//
//  Created by ShopLive on 2021/12/14.
//

import Foundation
import UIKit
import ShopLiveSDK
import ShopliveSDKCommon

@objc protocol DemoConfigurationObserver {
    var identifier: String { get }
    @objc optional func updatedValues(keys: [String])
}

final class DemoConfiguration: NSObject {

    static let shared: DemoConfiguration = .init()
    private var observers: [DemoConfigurationObserver?] = []

    private func notifyObservers(key: String) {
        self.observers.forEach { observer in
            observer?.updatedValues?(keys: [key])
        }
    }

    func addConfigurationObserver(observer: DemoConfigurationObserver) {
        if observers.contains(where: { $0?.identifier == observer.identifier }), let index = observers.firstIndex(where: { $0?.identifier == observer.identifier}) {
            observers.remove(at: index)
        }

        observers.append(observer)
    }

    var user: ShopLiveCommonUser {
        set {
            userId = newValue.userId
            userName = newValue.userName
            userAge = newValue.age
            userGender = newValue.gender
            userScore = newValue.userScore
            notifyObservers(key: "user")
        }
        get {
            var user = ShopLiveCommonUser(userId: userId ?? "null")
            user.userName = userName
            user.age = userAge
            user.gender = userGender
            user.userScore = userScore
            guard let params = self.userParameters else {
                return user
            }
            user.custom = params.compactMapValues({ $0 })
            return user
        }
    }

    private(set) var userId: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "userId")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "userId")
        }
    }

    var userName: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "userName")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "userName")
        }
    }

    var userAge: Int? {
        set {
            UserDefaults.standard.set(newValue, forKey: "userAge")
            UserDefaults.standard.synchronize()
        }
        get {
            guard let age = UserDefaults.standard.string(forKey: "userAge") else {
                return nil
            }
            return Int(age)
        }
    }

    var userGender: ShopliveCommonUserGender? {
        set {
            UserDefaults.standard.set(newValue?.rawValue, forKey: "userGender")
            UserDefaults.standard.synchronize()
        }
        get {
            guard let genderDescription = UserDefaults.standard.string(forKey: "userGender"), let gender = ShopliveCommonUserGender.allCases.first(where: {$0.rawValue == genderDescription}) else {
                return nil
            }
            return gender
        }
    }

    var userScore: Int? {
        set {
            UserDefaults.standard.set(newValue?.description, forKey: "userScore")
            UserDefaults.standard.synchronize()
        }
        get {
            guard let score = UserDefaults.standard.string(forKey: "userScore") else {
                return nil
            }
            return Int(score)
        }
    }

    var jwtToken: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "jwtToken")
            UserDefaults.standard.synchronize()
            notifyObservers(key: "jwtToken")
        }
        get {
            return UserDefaults.standard.string(forKey: "jwtToken")
        }
    }
    
    var userParameters: [String: Any?]? {
        set {
            UserDefaults.standard.set(newValue, forKey: "parameter")
            UserDefaults.standard.synchronize()
        }
        get {
            guard let list = UserDefaults.standard.dictionary(forKey: "parameter") else {
                return nil
            }
            return list as [String: Any?]
        }
    }
    
    var customParameters: [CustomParam] {
        set {
            do {
                UserDefaults.standard.set(try? PropertyListEncoder().encode(newValue), forKey:"customParameter")
                
                UserDefaults.standard.synchronize()
            } catch {
                
            }
        }
        get {
            var genres: [CustomParam]?
            if let data = UserDefaults.standard.value(forKey:"customParameter") as? Data {
                do {
                    genres = try? PropertyListDecoder().decode([CustomParam].self, from: data)
                } catch {
                    return []
                }
            }
            return genres ?? []
        }
    }

    var useHeadPhoneOption1: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.headphoneOption1.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.headphoneOption1.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey: SDKOptionType.headphoneOption1.optionKey)
        }
    }
    
    var useHeadPhoneOption2: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.headphoneOption2.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.headphoneOption2.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey: SDKOptionType.headphoneOption2.optionKey)
        }
    }

    var useCallOption: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.callOption.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.callOption.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey: SDKOptionType.callOption.optionKey)
        }
    }

    var useCustomShare: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.customShare.optionKey)
            notifyObservers(key: SDKOptionType.customShare.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey: SDKOptionType.customShare.optionKey)
        }
    }

    var shareScheme: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.shareScheme.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.shareScheme.optionKey)
        }
        get {
            return UserDefaults.standard.string(forKey:  SDKOptionType.shareScheme.optionKey)
        }
    }

    var progressColor: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.progressColor.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.progressColor.optionKey)
        }
        get {
            return UserDefaults.standard.string(forKey:  SDKOptionType.progressColor.optionKey)
        }
    }

    var useCustomProgress: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.customProgress.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.customProgress.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey: SDKOptionType.customProgress.optionKey)
        }
    }

    var useChatInputCustomFont: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.chatInputCustomFont.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.chatInputCustomFont.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.chatInputCustomFont.optionKey)
        }
    }

    var useChatSendButtonCustomFont: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.chatSendButtonCustomFont.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.chatSendButtonCustomFont.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.chatSendButtonCustomFont.optionKey)
        }
    }

    var downloadCouponSuccessMessage: String {
        set {
            UserDefaults.standard.set(newValue, forKey: CouponResponseKey.downloadCouponSuccessMessage.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let message = UserDefaults.standard.string(forKey: CouponResponseKey.downloadCouponSuccessMessage.key) ?? "couponresponse.success.default".localized()

            return message.isEmpty ? "couponresponse.success.default".localized() : message
        }
    }

    var downloadCouponSuccessStatus: ShopLiveResultStatus {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: CouponResponseKey.downloadCouponSuccessStatus.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let rawValue = UserDefaults.standard.integer(forKey: CouponResponseKey.downloadCouponSuccessStatus.key)
            return ShopLiveResultStatus(rawValue: rawValue) ?? .SHOW
        }
    }

    var downloadCouponSuccessAlertType: ShopLiveResultAlertType {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: CouponResponseKey.downloadCouponSuccessAlertType.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let rawValue = UserDefaults.standard.integer(forKey: CouponResponseKey.downloadCouponSuccessAlertType.key)
            return ShopLiveResultAlertType(rawValue: rawValue) ?? .ALERT
        }
    }

    var downloadCouponFailedMessage: String {
        set {
            UserDefaults.standard.set(newValue, forKey: CouponResponseKey.downloadCouponFailedMessage.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let message = UserDefaults.standard.string(forKey: CouponResponseKey.downloadCouponFailedMessage.key) ?? "couponresponse.failed.default".localized()

            return message.isEmpty ? "couponresponse.failed.default".localized() : message
        }
    }

    var downloadCouponFailedStatus: ShopLiveResultStatus {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: CouponResponseKey.downloadCouponFailedStatus.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let rawValue = UserDefaults.standard.integer(forKey: CouponResponseKey.downloadCouponFailedStatus.key)
            return ShopLiveResultStatus(rawValue: rawValue) ?? .SHOW
        }
    }

    var downloadCouponFailedAlertType: ShopLiveResultAlertType {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: CouponResponseKey.downloadCouponFailedAlertType.key)
            UserDefaults.standard.synchronize()
        }
        get {
            let rawValue = UserDefaults.standard.integer(forKey: CouponResponseKey.downloadCouponFailedAlertType.key)
            return ShopLiveResultAlertType(rawValue: rawValue) ?? .ALERT
        }
    }

    var customFont: UIFont? {
        let customFont: String = "NanumBrush"
        return UIFont(name: customFont, size: 16)
    }

    var pipPosition: ShopLive.PipPosition {
        set {
            UserDefaults.standard.set(newValue.rawValue + 1, forKey: SDKOptionType.pipPosition.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            let rawValue = UserDefaults.standard.integer(forKey: SDKOptionType.pipPosition.optionKey) - 1
            return ShopLive.PipPosition(rawValue: rawValue) ?? ShopLive.PipPosition.default
        }
    }

    var pipScale: CGFloat? {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.pipScale.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            guard let scale = UserDefaults.standard.string(forKey:  SDKOptionType.pipScale.optionKey), !scale.isEmpty else {
                return nil
            }

            if let scaleValue = scale.cgfloatValue, scaleValue <= 0.0 || scaleValue > 100.0 {
                return nil
            }

            return scale.cgfloatValue
        }
    }
    
    var maxPipSize: CGFloat? {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.maxPipSize.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            guard let pipSize = UserDefaults.standard.string(forKey:  SDKOptionType.maxPipSize.optionKey), !pipSize.isEmpty else {
                return nil
            }

            if let pipSize = pipSize.cgfloatValue, pipSize <= 0.0 {
                return nil
            }

            return pipSize.cgfloatValue
        }
    }
    
    var fixedHeightPipSize : CGFloat? {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.fixedHeightPipSize.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            guard let pipSize = UserDefaults.standard.string(forKey:  SDKOptionType.fixedHeightPipSize.optionKey), !pipSize.isEmpty else {
                return nil
            }

            if let pipSize = pipSize.cgfloatValue, pipSize <= 0.0 {
                return nil
            }

            return pipSize.cgfloatValue
        }
    }
    
    var fixedWidthPipSize : CGFloat? {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.fixedWidthPipSize.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            guard let pipSize = UserDefaults.standard.string(forKey:  SDKOptionType.fixedWidthPipSize.optionKey), !pipSize.isEmpty else {
                return nil
            }

            if let pipSize = pipSize.cgfloatValue, pipSize <= 0.0 {
                return nil
            }

            return pipSize.cgfloatValue
        }
    }
    
    var pipCornerRadius : CGFloat? {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.pipCornerRadius.optionKey)
            UserDefaults.standard.synchronize()
        }
        get {
            guard let pipCornerRadius = UserDefaults.standard.string(forKey:  SDKOptionType.pipCornerRadius.optionKey), !pipCornerRadius.isEmpty else {
                return nil
            }

            if let pipCornerRadius = pipCornerRadius.cgfloatValue, pipCornerRadius < 0.0 {
                return nil
            }

            return pipCornerRadius.cgfloatValue
        }
    }
    
    var isGuestMode: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "isGuestMode")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey:  "isGuestMode")
        }
    }

    var useJWT: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: "useJWT")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.bool(forKey:  "useJWT")
        }
    }
    
    var usePlayWhenPreviewTapped: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.playWhenPreviewTapped.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.playWhenPreviewTapped.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.playWhenPreviewTapped.optionKey)
        }
    }
    
    var useCloseButton: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.useCloseButton.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.useCloseButton.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.useCloseButton.optionKey)
        }
    }
    
    var nextActionTypeOnHandleNavigation: ActionType {
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: SDKOptionType.nextActionOnHandleNavigation.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.nextActionOnHandleNavigation.optionKey)
        }
        get {
            let value = UserDefaults.standard.integer(forKey:  SDKOptionType.nextActionOnHandleNavigation.optionKey)
            return ActionType(rawValue: value) ?? .PIP
        }
    }
    
    var isMuted: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.mute.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.mute.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.mute.optionKey)
        }
    }
    
    var enablePreviewSound: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.enablePreviewSound.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.enablePreviewSound.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.enablePreviewSound.optionKey)
        }
    }
    
    var pipPadding: UIEdgeInsets {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.pipPadding.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.pipPadding.optionKey)
        }
        get {
            let defPadding: UIEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20)
            guard let padding = UserDefaults.standard.cgRect(forKey: SDKOptionType.pipPadding.optionKey) else {
                return defPadding
            }
            
            return padding
        }
    }
    
    var pipFloatingOffset: UIEdgeInsets {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.pipFloatingOffset.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.pipFloatingOffset.optionKey)
        }
        get {
            let defPadding: UIEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
            guard let padding = UserDefaults.standard.cgRect(forKey: SDKOptionType.pipFloatingOffset.optionKey) else {
                return defPadding
            }
            
            return padding
        }
    }
    
    var useAspectOnTablet: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.aspectOnTablet.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.aspectOnTablet.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.aspectOnTablet.optionKey)
        }
    }
    
    var useKeepWindowStateOnPlayExecuted: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.keepWindowStateOnPlayExecuted.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.keepWindowStateOnPlayExecuted.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.keepWindowStateOnPlayExecuted.optionKey)
        }
    }
    
    var usePipKeepWindowStyle: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.pipKeepWindowStyle.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.pipKeepWindowStyle.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.pipKeepWindowStyle.optionKey)
        }
    }
    
    var enablePictureInPictureMode : Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.enablePictureInPictureMode.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.enablePictureInPictureMode.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.enablePictureInPictureMode.optionKey)
        }
    }
    
    var customLandingUrl: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "CUSTOM_LANDING_URL")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "CUSTOM_LANDING_URL") ?? ""
        }
    }
    
    var customLandingInput: String? = nil
    
    var useManualRotation: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.manualRotation.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.manualRotation.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.manualRotation.optionKey)
        }
    }
    
    var useMixAudio: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.mixAudio.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.mixAudio.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.mixAudio.optionKey)
        }
    }
    
    var useClickLog: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.clicklog.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.clicklog.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.clicklog.optionKey)
        }
    }

    var customAppVersion: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "customAppVersion")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "customAppVersion")
        }
    }
    
    var customReferrer: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "customReferrer")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "customReferrer")
        }
    }
    
    var utmSource: String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "utmSource")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "utmSource")
        }
    }
    
    var utmCampaign : String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "utmCampaign")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "utmCampaign")
        }
    }
    
    var utmContent : String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "utmContent")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "utmContent")
        }
    }
    
    var utmMedium : String? {
        set {
            UserDefaults.standard.set(newValue, forKey: "utmMedium")
            UserDefaults.standard.synchronize()
        }
        get {
            return UserDefaults.standard.string(forKey: "utmMedium")
        }
    }
    
    var pipEnableSwipeOut: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.pipEnableSwipeOut.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.pipEnableSwipeOut.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.pipEnableSwipeOut.optionKey)
        }
    }
    
    var useAutomaticallyPreservesTimeOffsetFromLive: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.automaticallyPreservesTimeOffsetFromLive.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.automaticallyPreservesTimeOffsetFromLive.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.automaticallyPreservesTimeOffsetFromLive.optionKey)
        }
    }
    
    var useStartsOnFirstEligibleVariant: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.startsOnFirstEligibleVariant.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.startsOnFirstEligibleVariant.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.startsOnFirstEligibleVariant.optionKey)
        }
    }
    
    var useVariantPreferencesScalabilityToLosslessAudio: Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.variantPreferences_scalabilityToLosslessAudio.optionKey)
            UserDefaults.standard.synchronize()
            notifyObservers(key: SDKOptionType.variantPreferences_scalabilityToLosslessAudio.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.variantPreferences_scalabilityToLosslessAudio.optionKey)
        }
    }
    
    var statusBarVisibility : Bool {
        set {
            UserDefaults.standard.set(newValue, forKey: SDKOptionType.statusBarVisibility.optionKey)
            notifyObservers(key: SDKOptionType.statusBarVisibility.optionKey)
        }
        get {
            return UserDefaults.standard.bool(forKey:  SDKOptionType.statusBarVisibility.optionKey)
        }
    }
}


