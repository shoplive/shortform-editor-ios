//
//  ShopliveSDKCommon.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation
import UIKit
import OSLog


public protocol ShopLiveCommonDelegate : NSObject {
    var identifier : String { get }
    func onChangedShopLiveUserJWT(to : String?)
    func onChangeShopLiveUser(to : ShopLiveCommonUser?)
}

@objc final public class ShopLiveCommon : NSObject {
    static var baseURLGenerator: ((HTTPVersion) -> String)?
    
    private static var delegate : [ShopLiveCommonDelegate] = []
   
    private static var _auth : ShopLiveCommonAuth?
    private static var auth : ShopLiveCommonAuth? {
        get {
            if _auth == nil {
                _auth = ShopLiveCommonAuth()
            }
            return _auth
        }
        set(newValue) {
            if let guestId = newValue?.guestUid {
                ShopLiveUserDefaults.guestId = guestId
            }
            _auth = newValue
        }
    }
    
    private static var _user : ShopLiveCommonUser?
    
    public static func setDelegate(delegate : ShopLiveCommonDelegate) {
        if Self.delegate.contains(where: { $0.identifier == delegate.identifier }) == false {
            Self.delegate.append(delegate)
        }
    }
    
    public static func removeDelegate(delegate : ShopLiveCommonDelegate) {
        Self.delegate.removeAll(where: { $0.identifier == delegate.identifier })
    }
}
//MARK: - common Auth
extension ShopLiveCommon {
    
    
    @objc(setAuthToken:)
    public static func setAuthToken(authToken : String?) {
        if auth?.customerUserJWT ?? "" != authToken {
            Self.delegate.forEach { delegate in
                delegate.onChangedShopLiveUserJWT(to: authToken)
            }
        }
        auth?.customerUserJWT = authToken
    }
    
    @objc public static func getAuthToken() -> String? {
        if let customerJwt = auth?.customerUserJWT {
            return customerJwt
        }
        else {
            return auth?.generatedUserJWT
        }
    }
    
    //플레이어에서는 일반 인증의 경우 generated 된 jwt를 아예 안쓰는 것으로 협의 됨 2024/06/17
    @objc public static func getAuthTokenForPlayer() -> String? {
        return auth?.customerUserJWT
    }
    
    
    @objc public static func getUser() ->  ShopLiveCommonUser? {
        return _user
    }
    
    @objc(setUser:accessKey:)
    public static func setUser(user : ShopLiveCommonUser?, accessKey : String?) {
        _user = user
        guard let accessKey = accessKey else {
            os_log("[Shoplive] failed to create authToken because accessKey is not defined", type: .error)
            return
        }
        if let user = user, let jwtToken = ShopLiveJWT.make(accessKey: accessKey, userData: user) {
            auth?.generatedUserJWT = jwtToken
            Self.delegate.forEach { delegate in
                delegate.onChangedShopLiveUserJWT(to: jwtToken)
                delegate.onChangeShopLiveUser(to: user)
            }
        }
        else {
            auth?.generatedUserJWT = nil
        }
    }
    
    @objc(setUser:)
    public static func setUser(user : ShopLiveCommonUser?) {
        Self.setUser(user: user, accessKey: ShopLiveCommon.getAccessKey())
    }
    
    @available(iOS, deprecated, message: "Enable AppTrackingTransparency instead")
    @objc public static func setAdId(adId : String?) {
        auth?.adId = adId
    }
    
    @available(iOS, deprecated, message: "Enable AppTrackingTransparency instead")
    @objc public static func getAdId() -> String? {
        return auth?.adId
    }

    @objc public static func getAdIdentifier() -> String? {
        return auth?.adIdentifier
    }
    
    @objc(setUtmSource:)
    public static func setUtmSource(utmSource : String?){
        auth?.utmSource = utmSource
    }
    
    @objc(setUtmMedium:)
    public static func setUtmMedium(utmMedium : String?){
        auth?.utmMedium = utmMedium
    }
    
    @objc(setUtmCampaign:)
    public static func setUtmCampaign(utmCampaign : String?){
        auth?.utmCampaign = utmCampaign
    }
    
    @objc(setUtmContent:)
    public static func setUtmContent(utmContent : String?){
        auth?.utmContent = utmContent
    }
    
    @objc public static func getUtmSource() -> String? {
        return auth?.utmSource
    }
    
    @objc public static func getUtmMedium() -> String? {
        return auth?.utmMedium
    }
    
    @objc public static func getUtmCampaign() -> String? {
        return auth?.utmCampaign
    }
    
    @objc public static func getUtmContent() -> String? {
        return auth?.utmContent
    }

    @objc(setAccessKey:)
    public static func setAccessKey(accessKey : String?){
        auth?.accessKey = accessKey
    }

    @objc public static func getAccessKey() -> String? {
        return auth?.accessKey
    }

    @objc(setGuestUid:)
    public static func setGuestUid(guestUid : String?){
        auth?.guestUid = guestUid
    }
    
    @objc public static func getGuestUid() -> String? {
        if let _ = Self.getAuthToken() {
            return nil
        }
        return auth?.guestUid
    }
    
    @objc(setAnonId:)
    public static func setAnonId(anonId : String?) {
        auth?.anonId = anonId
    }
    
    @objc public static func getAnonId() -> String? {
        return auth?.anonId
    }
    
    @objc public static func getCeId() -> String? {
        if ShopLiveUserDefaults.ceId == nil {
            ShopLiveUserDefaults.ceId = ShopliveCeId.makeShopliveCeId()
        }
        return ShopLiveUserDefaults.ceId
    }
    
    @objc public static func clearAuth() {
        auth = nil
    }
    
    @objc public static func isLoggedIn() -> Bool {
        if auth != nil {
            return true
        }
        else if self.getAuthToken() != nil {
            return true
        }
        else {
            return false
        }
    }
    
}

extension ShopLiveCommon {
    @objc public static func makeShopLiveSessionId() -> String {
        return ShopLiveSession.makeShopLiveSessionId()
    }
}
public extension ShopLiveCommon {
    @objc static var sdkVersion: String {
        return "1.7.5"
    }
    
    @objc static var playerSdkVersion : String {
        return "1.7.5"
    }
    
    @objc static var shortformSdkVersion : String {
        return "1.7.5"
    }
    
    @objc static var videoEditorSdkversion : String {
        return "1.7.5"
    }
}

//MARK: - Font
extension ShopLiveCommon {
    private static var fontFamily: UIFont? = nil
    
    public static func setFontFamily(font: String) {
        ShopLiveCommon.fontFamily = .init(name: font, size: 16)
    }
    public static func getFontFamily() -> UIFont? {
        ShopLiveCommon.fontFamily
    }
}
