//
//  NSObject+extension.swift
//  ShopliveSDKCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation

public extension NSObject {
    func safeRemoveObserver_SL(_ observer: Any, forKeyPath keyPath: String) {
        guard let obverb: NSObject = observer as? NSObject else { return }
        
        switch self.observationInfo {
        case .some:
            self.removeObserver(obverb, forKeyPath: keyPath)
        default:
            break

        }
    }
    
    private func propertyNames_SL() -> [String] {
        let mirror = Mirror(reflecting: self)
        return mirror.children.compactMap{ $0.label }
    }
}

public protocol AnyNameable {
    static func className() -> String
}

public extension AnyNameable {
    static func className() -> String {
        return String(describing: self)
    }
}

extension NSObject: AnyNameable {}
