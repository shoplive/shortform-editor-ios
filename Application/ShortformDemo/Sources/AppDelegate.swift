//
//  AppDelegate.swift
//  shortform-examples
//
//  Created by Vincent on 1/25/23.
//

import UIKit
import Firebase
//#if(canImport(IQKeyboardManagerSwift))
//import IQKeyboardManagerSwift
//#endif
import ShopliveSDKCommon
import AdSupport
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        ShopLiveCommon.setUtmSource(utmSource: "test_utm_source")
        ShopLiveCommon.setUtmContent(utmContent: "test_utm_content")
        ShopLiveCommon.setUtmMedium(utmMedium: "test_utm_medium")
        ShopLiveCommon.setUtmCampaign(utmCampaign: "test_utm_campaign")
        
       
        
        return true
    }

    
    func requestIDFAPermission(completion: @escaping (String)->()) {
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                switch status {
                    
                case .authorized:
                    print("adId Authorized")
                    completion(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
                case .denied, .notDetermined, .restricted:
                    print("adId Not Authorized")
                    completion(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
                @unknown default:
                    print("adId UNKNOWN")
                    completion(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
                }
            }
        } else {
            print("Under 14.0")
            completion(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
        }
    }
    
    
    // MARK: UISceneSession Lifecycle

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return .all
    }
    

}

