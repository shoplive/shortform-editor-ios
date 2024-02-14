//
//  UIFont + extension.swift
//  matrix-shortform-ios
//
//  Created by sangmin han on 2023/05/02.
//

import Foundation
import UIKit


extension UIFont {
    
    enum FigmaWeight {
        case _400
        case _500
        case _600
        case _700
    }
    
    static func set(size : CGFloat,weight : FigmaWeight ) -> UIFont {
        var w : UIFont.Weight = .regular
        switch weight {
        case ._400:
            w = .regular
        case ._500:
            w = .semibold
        case ._600:
            w = .bold
        case ._700:
            w = .bold
        }
        
        return UIFont.systemFont(ofSize: size, weight: w)
    }
    
    
    
    
}
