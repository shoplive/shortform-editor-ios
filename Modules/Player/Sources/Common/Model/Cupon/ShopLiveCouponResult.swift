//
//  CuponResult.swift
//  ShopLiveSDK
//
//  Created by yong C on 8/6/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import ShopliveSDKCommon
import UIKit

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

    @objc public init(couponId: String, success: Bool, message: String?, status: ResultStatus, alertType: ResultAlertType) {
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

    @objc public init(id: String, success: Bool, message: String?, status: ResultStatus, alertType: ResultAlertType) {
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

    @objc public init(couponId: String, success: Bool, message: String?, status: ShopLiveResultStatus, alertType: ShopLiveResultAlertType) {
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

    @objc public init(id: String, success: Bool, message: String?, status: ShopLiveResultStatus, alertType: ShopLiveResultAlertType) {
        self.id = id
        self.success = success
        self.message = message
        self.couponStatus = status
        self.alertType = alertType
    }
}
