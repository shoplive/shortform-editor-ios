//
//  NotificationCenter+extension.swift
//  ShopLiveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation

public extension NotificationCenter {
    func safeRemoveObserver_SL(_ observer: Any, name aName: NSNotification.Name?, object anObject: Any?) {
        guard let obverb: NSObject = observer as? NSObject else { return }
        
        switch self.observationInfo {
        case .some:
            self.removeObserver(obverb, name: aName, object: anObject)
        default:
            break

        }
    }
}
