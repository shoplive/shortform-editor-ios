//
//  SDKSettings.swift
//  ShopLiveSwiftSample
//
//  Created by ShopLive on 2021/11/08.
//

import Foundation
import UIKit

final class SDKSettings {

    private static var ud: UserDefaults = UserDefaults.standard

    enum LoadingImageType: Int {
        case type1
        case type2

        var images: [UIImage] {
            return makeLoadingImageArray()
        }

        private var imageTitle: String {
            switch self {
            case .type1:
                return "loading"
            case .type2:
                return "loading2_"
            }
        }

        private func makeLoadingImageArray() -> [UIImage] {
            var images: [UIImage] = []

            for i in 1...11 {
                images.append(.init(named: "\(imageTitle)\(i)")!)
            }
            return images
        }

    }

    enum SettingKey: String {
        case downloadCouponSuccessMessage
        case downloadCouponSuccessStatus
        case downloadCouponSuccessAlertType
        case downloadCouponFailedMessage
        case downloadCouponFailedStatus
        case downloadCouponFailedAlertType

        var key: String {
            self.rawValue
        }
    }

    static var downloadCouponSuccessMessage: String {
        set {
            ud.set(newValue, forKey: SettingKey.downloadCouponSuccessMessage.key)
            ud.synchronize()
        }
        get {
            ud.string(forKey: SettingKey.downloadCouponSuccessMessage.key) ?? ""
        }
    }

    static var downloadCouponSuccessStatus: ShopLive.ResultStatus {
        set {
            ud.set(newValue.rawValue, forKey: SettingKey.downloadCouponSuccessStatus.key)
            ud.synchronize()
        }
        get {
            let rawValue = ud.integer(forKey: SettingKey.downloadCouponSuccessStatus.key)
            return ShopLive.ResultStatus(rawValue: rawValue) ?? .SHOW
        }
    }

    static var downloadCouponSuccessAlertType: ShopLive.ResultAlertType {
        set {
            ud.set(newValue.rawValue, forKey: SettingKey.downloadCouponSuccessAlertType.key)
            ud.synchronize()
        }
        get {
            let rawValue = ud.integer(forKey: SettingKey.downloadCouponSuccessAlertType.key)
            return ShopLive.ResultAlertType(rawValue: rawValue) ?? .ALERT
        }
    }

    static var downloadCouponFailedMessage: String {
        set {
            ud.set(newValue, forKey: SettingKey.downloadCouponFailedMessage.key)
            ud.synchronize()
        }
        get {
            ud.string(forKey: SettingKey.downloadCouponFailedMessage.key) ?? ""
        }
    }

    static var downloadCouponFailedStatus: ShopLive.ResultStatus {
        set {
            ud.set(newValue.rawValue, forKey: SettingKey.downloadCouponFailedStatus.key)
            ud.synchronize()
        }
        get {
            let rawValue = ud.integer(forKey: SettingKey.downloadCouponFailedStatus.key)
            return ShopLive.ResultStatus(rawValue: rawValue) ?? .SHOW
        }
    }

    static var downloadCouponFailedAlertType: ShopLive.ResultAlertType {
        set {
            ud.set(newValue.rawValue, forKey: SettingKey.downloadCouponFailedAlertType.key)
            ud.synchronize()
        }
        get {
            let rawValue = ud.integer(forKey: SettingKey.downloadCouponFailedAlertType.key)
            return ShopLive.ResultAlertType(rawValue: rawValue) ?? .ALERT
        }
    }

}
