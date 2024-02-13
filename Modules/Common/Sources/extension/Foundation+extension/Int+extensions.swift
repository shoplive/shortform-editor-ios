//
//  Int+extensions.swift
//  ShopliveCommon
//
//  Created by Vincent on 1/24/23.
//

import Foundation

public extension Int {
    func addCommas_SL() -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        return numberFormatter.string(from: NSNumber(value: self)) ?? ""
    }
    
    var toJsonValue_SL: String {
        "\(self)"
    }
}
