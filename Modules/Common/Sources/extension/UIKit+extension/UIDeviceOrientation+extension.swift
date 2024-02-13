//
//  UIDeviceOrientation+extension.swift
//  ShopliveCommonLibrary
//
//  Created by James Kim on 11/24/22.
//

import UIKit

public extension UIDeviceOrientation {
    var interfaceOrientation_SL: UIInterfaceOrientation {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portraitUpsideDown
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return self.isLandscape ? .landscapeRight : .portrait
        }
    }
    
    var orientationMask_SL: UIInterfaceOrientationMask {
        switch self {
        case .portrait:
            return .portrait
        case .portraitUpsideDown:
            return .portrait
        case .landscapeLeft:
            return .landscapeRight
        case .landscapeRight:
            return .landscapeLeft
        default:
            return self.isLandscape ? .landscapeRight : .portrait
        }
    }
}
