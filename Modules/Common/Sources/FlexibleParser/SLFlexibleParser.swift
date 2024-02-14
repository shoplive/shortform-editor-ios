//
//  SLFlexibleParser.swift
//  ShopliveSDKCommon
//
//  Created by sangmin han on 1/24/24.
//

import Foundation
import UIKit

public struct SLFlexibleParser<K : CodingKey> {
    
    private var container : KeyedDecodingContainer<K>?
    
    public init(container : KeyedDecodingContainer<K>) {
        self.container = container
    }
    
    public func parse<T>(targetType : T.Type, key : CodingKey ) throws -> T? {
        
        guard let container = container else {
            return nil
        }
        guard let Key = key as? K else {
            return nil
        }
        
        var result : T?
        if T.self is Double.Type {
            if let originValue = try? container.decodeIfPresent(Double.self, forKey: Key) {
                result = originValue as? T
            }
            else if let stringValue = try? container.decodeIfPresent(String.self, forKey: Key) {
                let doublevalue = Double(stringValue)
                result = doublevalue as? T
            }
            else if let boolValue = try? container.decodeIfPresent(Bool.self, forKey: Key) {
                let doubleValue = boolValue == true ? 1 : 0
                result = doubleValue as? T
            }
            else {
                result = nil
            }
        }
        else if T.self is String.Type {
            if let originValue = try? container.decodeIfPresent(String.self, forKey: Key) {
                result = originValue as? T
            }
            else if let intValue = try? container.decodeIfPresent(Int.self, forKey: Key) {
                let stringValue = String(intValue)
                result = stringValue as? T
            }
            else if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: Key) {
                let stringValue = String(doubleValue)
                result = stringValue as? T
            }
            else if let boolValue = try? container.decodeIfPresent(Bool.self, forKey: Key) {
                let stringValue = boolValue == true ? "true" : "false"
                result = stringValue as? T
            }
            else {
                result = nil
            }
        }
        else if T.self is Int.Type {
            if let originValue = try? container.decode(Int.self, forKey: Key) {
                result = originValue as? T
            }
            else if let doubleValue = try? container.decode(Double.self, forKey: Key) {
                let intValue = Int(doubleValue)
                result = intValue as? T
            }
            else if let stringValue = try? container.decode(String.self, forKey: Key) {
                if let intValue = Int(stringValue) {
                    result = intValue as? T
                }
                else {
                    result = nil
                }
            }
        }
        else if T.self is CGFloat.Type {
            if let originValue = try? container.decodeIfPresent(CGFloat.self, forKey: Key) {
                result = originValue as? T
            }
            else if let stringValue = try? container.decodeIfPresent(String.self, forKey: Key) {
                if let doubleValue = Double(stringValue)  {
                    result = CGFloat(doubleValue) as? T
                }
                else {
                    result = nil
                }
            }
            else if let boolValue = try? container.decodeIfPresent(Bool.self, forKey: Key) {
                result = nil
            }
        }
        else if T.self is Bool.Type {
            if let originValue = try? container.decodeIfPresent(Bool.self, forKey: Key) {
                result = originValue as? T
            }
            else if let intValue = try? container.decodeIfPresent(Int.self, forKey: Key) {
                if intValue == 0 {
                    result = false as? T
                }
                else if intValue == 1 {
                    result = true as? T
                }
                else {
                    result = nil
                }
            }
            else if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: Key) {
                let intValue = Int(doubleValue)
                if intValue == 0 {
                    result = false as? T
                }
                else if intValue == 1 {
                    result = true as? T
                }
                else {
                    result = nil
                }
            }
            else if let stringValue = try? container.decodeIfPresent(String.self, forKey: Key) {
                if stringValue == "0" || stringValue == "false" {
                    result = false as? T
                }
                else if stringValue == "1" || stringValue == "true" {
                    result = true as? T
                }
                else {
                    result = nil
                }
            }
        }
        // arrays
        else if T.self is [Bool].Type {
            if let originValue = try? container.decodeIfPresent([Bool].self, forKey: Key) {
                result = originValue as? T
            }
            else if let stringValue = try? container.decodeIfPresent([String].self, forKey: Key) {
                let boolValue = stringValue.map({ ($0 == "true" || $0 == "1") ? true : false })
                result = boolValue as? T
            }
            else if let intValue = try? container.decodeIfPresent([Int].self, forKey: Key) {
                let boolValue = intValue.map({ $0 == 1 ? true : false })
                result = boolValue as? T
            }
            else {
                result = nil
            }
        }
        else if T.self is [Double].Type {
            if let originValue = try? container.decodeIfPresent([Double].self, forKey: Key) {
                result = originValue as? T
            }
            else if let stringValue = try? container.decodeIfPresent([String].self, forKey: Key) {
                let doubleValue = stringValue.map({ Double($0) ?? 0.0 })
                result = doubleValue as? T
            }
            else {
                result = nil
            }
            
        }
        else if T.self is [Int].Type {
            if let originValue = try? container.decodeIfPresent([Int].self, forKey: Key) {
                result = originValue as? T
            }
            else if let stringValue = try? container.decodeIfPresent([String].self, forKey: Key) {
                let intValue = stringValue.map({ Int($0) ?? 0 })
                result = intValue as? T
            }
            else if let doubleValue = try? container.decodeIfPresent([Double].self, forKey: Key) {
                let intValue = doubleValue.map({ Int($0) })
                result = intValue as? T
            }
            else {
                result = nil
            }
        }
        else if T.self is [String].Type {
            if let originValue = try? container.decodeIfPresent([String].self, forKey: Key) {
                result = originValue as? T
            }
            else {
                result = nil
            }
        }
        else if T.self is [CGFloat].Type {
            if let originValue = try? container.decodeIfPresent([CGFloat].self, forKey: Key) {
                result = originValue as? T
            }
            else {
                result = nil
            }
        }
        return result
    }
}
