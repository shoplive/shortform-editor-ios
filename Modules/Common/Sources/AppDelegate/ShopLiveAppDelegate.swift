//
//  ShopLiveAppDelegate.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 2023/06/01.
//

import Foundation
import UIKit


@objc public protocol ShopLiveAppDelegateHandler : AnyObject {
    @objc optional func application(_ application : UIApplication,_ window : UIWindow?,_ orientation : UIInterfaceOrientationMask)
}

class ShopLiveAppDelegate : NSObject, UIApplicationDelegate {
    static let shared = ShopLiveAppDelegate()
    
    private var orientations : UIInterfaceOrientationMask = .portrait
    private var enableOrientationSwizzle : Bool = true
    weak var delegate : ShopLiveAppDelegateHandler?
    
}
//MARK: - orientation swizzle
extension ShopLiveAppDelegate {
    
    func setEnableOrientationSwizzle(enable : Bool){
        self.enableOrientationSwizzle = enable
    }
    
    func getEnableOrientationSwizzle() -> Bool {
        return self.enableOrientationSwizzle
    }
    
    func setOrientation(_ orientation : UIInterfaceOrientationMask){
        self.orientations = orientation
    }
    
    @objc func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if let delegate = delegate {
            delegate.application?(application, window, orientations)
        }
        return orientations
    }
    
    func swizzleSupportedInterfaceOrientation(){
        if enableOrientationSwizzle == false { return }
        let appDelegate = UIApplication.shared.delegate
        let appDelegateClass: AnyClass? = object_getClass(appDelegate)
        
        let originalSelector = #selector(UIApplicationDelegate.application(_:supportedInterfaceOrientationsFor:))
        let swizzledSelector = #selector(ShopLiveAppDelegate.self.application(_:supportedInterfaceOrientationsFor:))
        
        guard let swizzledMethod = class_getInstanceMethod(ShopLiveAppDelegate.self, swizzledSelector) else {
            return
        }
        
        if let originalMethod = class_getInstanceMethod(appDelegateClass, originalSelector)  {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        } else {
            class_addMethod(appDelegateClass, swizzledSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
        }
    }
    
    func deswizzleSupportedInterfaceOrientation(){
        if enableOrientationSwizzle == false { return }
        let appDelegate = UIApplication.shared.delegate
        let appDelegateClass: AnyClass? = object_getClass(appDelegate)
        
        let originalSelector = #selector(UIApplicationDelegate.application(_:supportedInterfaceOrientationsFor:))
        let swizzledSelector = #selector(ShopLiveAppDelegate.self.application(_:supportedInterfaceOrientationsFor:))
        
        guard let swizzledMethod = class_getInstanceMethod(ShopLiveAppDelegate.self, swizzledSelector) else {
            return
        }
        
        if let originalMethod = class_getInstanceMethod(appDelegateClass, originalSelector)  {
            method_exchangeImplementations(swizzledMethod, originalMethod)
        }
    }
}
