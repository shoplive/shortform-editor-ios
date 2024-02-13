//
//  NSLayoutConstraint+extension.swift
//  ShopLiveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation
import UIKit

public extension NSLayoutConstraint {
    func updateConstraint_SL(value: NSLayoutConstraint?) {
        guard let newConstraint = value else { return }
        NSLayoutConstraint.deactivate([self])

        NSLayoutConstraint.activate([newConstraint])
    }
    
    func setMultiplier_SL(multiplier:CGFloat) -> NSLayoutConstraint {

        NSLayoutConstraint.deactivate([self])

        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)

        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier

        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
