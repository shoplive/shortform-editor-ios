//
//  Constants.swift
//  Shoplive Studio
//
//  Created by ShopLive on 2021/09/02.
//

import Foundation
import UIKit


public final class ShopLiveDefines: NSObject {
    static let appVersion = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
    static let buildVersion = (Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String) ?? ""

    static let osVersion = UIDevice.current.systemVersion
    static let osType: String = "i" // i: iOS, a: ANDROID, u: UNKNOWN
}
