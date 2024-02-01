//
//  ShopLivePlayerShareDelegate.swift
//  ShopLiveSDK
//
//  Created by sangmin han on 1/30/24.
//

import Foundation


@objc public protocol ShopLivePlayerShareDelegate : AnyObject {
    @objc func handleShare(data : ShopLivePlayerShareData)
}


