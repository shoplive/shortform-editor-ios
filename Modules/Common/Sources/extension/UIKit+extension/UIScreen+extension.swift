//
//  UIScreen+extension.swift
//  ShopliveCommonLibrary
//
//  Created by James Kim on 11/24/22.
//

import UIKit

public extension UIScreen {
    static var currentOrientation_SL: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.windows
                .first?
                .windowScene?
                .interfaceOrientation ?? UIDevice.current.orientation.interfaceOrientation_SL
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
    
    static var isLandscape_SL: Bool {
        currentOrientation_SL.isLandscape
    }
    
    static var concreteWidth_SL: CGFloat {
        UIScreen.main.bounds.width < UIScreen.main.bounds.height ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
    }
    
    static var concreteHeight_SL: CGFloat {
        UIScreen.main.bounds.width < UIScreen.main.bounds.height ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
    }
    
    static var landscapeWidth_SL: CGFloat {
        UIScreen.main.bounds.width > UIScreen.main.bounds.height ? UIScreen.main.bounds.width : UIScreen.main.bounds.height
    }
    
    static var landscapeHeight_SL: CGFloat {
        UIScreen.main.bounds.width > UIScreen.main.bounds.height ? UIScreen.main.bounds.height : UIScreen.main.bounds.width
    }
    
    static var screenWidth_SL: CGFloat {
        isLandscape_SL ? landscapeWidth_SL : concreteWidth_SL
    }
    
    static var screenHeight_SL: CGFloat {
        isLandscape_SL ? landscapeHeight_SL : concreteHeight_SL
    }
    
    static var concreteTopSafeArea_SL: CGFloat {
        let tops = isLandscape_SL ? (currentOrientation_SL == .landscapeLeft ? safeArea_SL.left : safeArea_SL.right) : (currentOrientation_SL == .portrait ? safeArea_SL.top : safeArea_SL.bottom)
        
        return tops
    }
    
    static var topSafeArea_SL: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            return window?.safeAreaInsets.top ?? 0
        } else {
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets.top ?? 0
        }
    }
    
    static var leftSafeArea_SL: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.windowList_SL?.filter({ $0.frame == main.bounds && $0.safeAreaInsets != .zero }).first
            return window?.safeAreaInsets.left ?? 0
        } else {
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets.left ?? 0
        }
    }
    
    static var rightSafeArea_SL: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.windowList_SL?.filter({ $0.frame == main.bounds && $0.safeAreaInsets != .zero }).first
            return window?.safeAreaInsets.right ?? 0
        } else {
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets.right ?? 0
        }
    }
    
    static var bottomSafeArea_SL: CGFloat {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.first
            return window?.safeAreaInsets.bottom ?? 0
        } else {
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets.bottom ?? 0
        }
    }
    
    static var safeArea_SL: UIEdgeInsets {
        if #available(iOS 13.0, *) {
            let window = UIApplication.shared.windows.filter({ $0.frame == main.bounds && $0.safeAreaInsets != .zero }).first
            
            return window?.safeAreaInsets ?? .zero
        } else {
            let window = UIApplication.shared.keyWindow
            return window?.safeAreaInsets ?? .zero
        }
    }
}
