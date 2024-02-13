//
//  UIEdgetInset+extension.swift
//  ShopliveCommon
//
//  Created by James Kim on 12/27/22.
//

import UIKit

public extension UIEdgeInsets {
    static var leastMargin_SL: UIEdgeInsets {
        return UIEdgeInsets(top: .leastNormalMagnitude,
                            left: .leastNormalMagnitude,
                            bottom: .leastNormalMagnitude,
                            right: .leastNormalMagnitude)
    }
}
