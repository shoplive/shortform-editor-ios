//
//  UIDevice+extension.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation
import UIKit

public extension UIDevice {
    static var isIpad_SL: Bool {
        self.current.userInterfaceIdiom == .pad
    }
    
    static var deviceIdentifier_sl : String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        return identifier
    }
}

