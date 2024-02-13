//
//  String+extension.swift
//  ShopLiveShortformUploadSDK
//
//  Created by 김우현 on 5/25/23.
//

import Foundation
import ShopliveSDKCommon

extension String {
    func localizedString(from: String = "Localizable", bundle: Bundle, comment: String = "") -> String {
        return bundle.localizedString(forKey: self, value: nil, table: from)
    }
    
    func localizedString(with argument: [CVarArg] = [], from: String = "Localizable", bundle: Bundle, comment: String = "") -> String {
        return String(format: bundle.localizedString(forKey: self, value: nil, table: from), argument)
    }
}
