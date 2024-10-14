//
//  AppDelegate.swift
//  SwiftDemo
//
//  Created by ShopLive on 2021/05/23.
//

import UIKit
import ShopLiveSDK
import ShopliveSDKCommon
import AdSupport
import AppTrackingTransparency

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var rootViewController: UINavigationController?
    var window: UIWindow?
    var orientationLock = UIInterfaceOrientationMask.all
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        if !UserDefaults.standard.bool(forKey: "streamOptionInitialized") {
            DemoConfiguration.shared.useAutomaticallyPreservesTimeOffsetFromLive = true
            DemoConfiguration.shared.useStartsOnFirstEligibleVariant = true
            DemoConfiguration.shared.useVariantPreferencesScalabilityToLosslessAudio = true
            
            DemoConfiguration.shared.useCallOption = true
            UserDefaults.standard.set(true, forKey: "streamOptionInitialized")
            UserDefaults.standard.synchronize()
        }
        
        UserDefaults.standard.register(defaults: [SDKOptionType.enablePictureInPictureMode.optionKey: true,
                                                  SDKOptionType.pipEnableSwipeOut.optionKey: true,
                                                  "playerPhase": "DEV",
                                                  "isGuestMode": true,
                                                  SDKOptionType.statusBarVisibility.optionKey : true,
                                                  SDKOptionType.playWhenPreviewTapped.optionKey : true,
                                                  SDKOptionType.enablePreviewSound.optionKey : false,
                                                  SDKOptionType.enablePip.optionKey : true,
                                                  SDKOptionType.enableOSPip.optionKey : true,
                                                  SDKOptionType.resizeMode.optionKey : "CENTER_CROP",
                                                  SDKOptionType.isEnabledVolumeKey.optionKey : false,
                                                  SDKOptionType.previewResolution.optionKey : "PREVIEW"                                                ])
        

        return true
    }
    
    func requestIDFAPermission(completion: @escaping (String)->()) {
        
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                switch status {
                    
                case .authorized:
                    print("Authorized")
                    completion(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
                case .denied, .notDetermined, .restricted:
                    print("Not Authorized")
                    completion(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
                @unknown default:
                    print("UNKNOWN")
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

    func applicationWillTerminate(_ application: UIApplication) {
        ShopLive.onTerminated()
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let shopLiveWindow = ShopLive.playerWindow, shopLiveWindow == window {
            return .all
        }
        return .portrait
    }
    
}
