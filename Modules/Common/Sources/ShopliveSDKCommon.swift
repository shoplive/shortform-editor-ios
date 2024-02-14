//
//  ShopliveSDKCommon.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation


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
        if auth?.userJWT ?? "" != authToken {
            Self.delegate.forEach { delegate in
                delegate.onChangedShopLiveUserJWT(to: authToken)
            }
        }
        auth?.userJWT = authToken
    }
    
    @objc public static func getAuthToken() -> String? {
       return auth?.userJWT
    }
    
    @objc public static func getUser() ->  ShopLiveCommonUser? {
        return _user
    }
    
    @objc(setUser:)
    public static func setUser(user : ShopLiveCommonUser?){
        _user = user
    }
    
    @available(iOS, deprecated, message: "Enable AppTrackingTransparency instead")
    @objc public static func setAdId(adId : String?) {
        auth?.adId = adId
    }
    
    @available(iOS, deprecated, message: "nable AppTrackingTransparency instead")
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
        if auth?.userJWT != nil {
            return nil
        }
        return auth?.guestUid
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
        return "1.5.5"
    }
}



