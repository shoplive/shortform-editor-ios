//
//  UIApplication+extension.swift
//  ShopliveCommonLibrary
//
//  Created by James Kim on 11/25/22.
//

import UIKit

public extension UIApplication {
    static var isLandscape_SL: Bool {
        UIScreen.main.bounds.width > UIScreen.main.bounds.height
    }

    static func openSettings_SL() {
        let settingsUrl = URL(string: UIApplication.openSettingsURLString)
        if let url = settingsUrl {
            shared.open(url, options: [:])
        }
    }

    static func openBrowser_SL(url: String) {
        guard let url = URL(string: url),
        UIApplication.shared.canOpenURL(url) else {
            return
        }

        UIApplication.shared.openURL(url)
    }

    static func openAppstore_SL(appId: String) {
        // id362057947 kakaotalk
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appId)"),   //\(appId)"),
           UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
           } else {
               UIApplication.shared.openURL(url)
           }
        }
    }
    
    class func appVersion_SL() -> String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }

    class func appBuild_SL() -> String {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
    }

    class func versionBuild_SL() -> String {
        let version = appVersion_SL(), build = appBuild_SL()

        return version == build ? "v\(version)" : "v\(version)(\(build))"
    }
     
    static var topWindow_SL: UIWindow? {
        if #available(iOS 15.0, *) {
            let scenes = UIApplication.shared.connectedScenes
            let windowScene = scenes.first as? UIWindowScene
            return windowScene?.windows.first
        } else {
            if #available(iOS 13.0, *) {
                return UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
            } else {
                return UIApplication.shared.windows.first(where: { $0.isKeyWindow })
            }
        }
    }
    
    static var firstWindow_SL: UIWindow? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
                .first(where: \.isKeyWindow)
        } else {
            return (UIApplication.shared.windows.first(where: { $0.isKeyWindow }))
        }
    }
    
    static var windowList_SL: [UIWindow]? {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
        } else {
            return UIApplication.shared.windows
        }
    }
    
}
