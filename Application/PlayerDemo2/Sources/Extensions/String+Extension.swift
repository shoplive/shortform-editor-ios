//
//  String+Extension.swift
//  PlayerDemo2
//
//  Created by Tabber on 1/17/25.
//  Copyright © 2025 com.app. All rights reserved.
//

import Foundation

extension String {

    func localized(from: String = "shoplive", comment: String = "") -> String {
        return Bundle.main.localizedString(forKey: self, value: nil, table: from)
    }

    func localized(with argument: CVarArg = [], from: String = "shoplive", comment: String = "") -> String {
        return String(format: self.localized(from: from, comment: comment), argument)
    }

    var cgfloatValue: CGFloat? {
        return CGFloat((self as NSString).floatValue)
    }

    var toJsonValue: String {
        "\"\(self)\""
    }

    var base64Decoded: String? {
       guard let decodedData = Data(base64Encoded: self) else { return nil }
       return String(data: decodedData, encoding: .utf8)
    }

    var base64Encoded: String? {
        let plainData = data(using: .utf8)
        return plainData?.base64EncodedString()
    }
}

extension String {
  func CGFloatValue() -> CGFloat? {
    guard let doubleValue = Double(self) else {
      return nil
    }

    return CGFloat(doubleValue)
  }
}
