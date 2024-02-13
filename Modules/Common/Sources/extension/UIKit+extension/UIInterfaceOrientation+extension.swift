//
//  UIInterfaceOrientation+extension.swift
//  ShopliveCommonLibrary
//
//  Created by James Kim on 11/25/22.
//

import UIKit

public extension UIInterfaceOrientation {
    var angl_SLe: CGFloat {
        switch self {
        case .portrait:
            return 0
        case .portraitUpsideDown:
            return 180
        case .landscapeRight:
            return 270
        case .landscapeLeft:
            return 90
        default:
            return 0
        }
    }
    
    var deviceOrientation_SL: UIDeviceOrientation {
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
            return .portrait
        }
    }
}
