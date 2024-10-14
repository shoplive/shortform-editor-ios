//
//  Double + Extension.swift
//  ShopLiveShortformSDK
//
//  Created by sangmin han on 2023/06/21.
//

import Foundation


extension Double {
    
    func currency(currencyCode : String?) -> String {
        guard let currencyCode = currencyCode else {
            return self.fractionFormatter(maxFractionDigit: 2, locale: .current)
        }
        switch currencyCode {
        case "EUR":
            return "€" + self.fractionFormatter(maxFractionDigit: 2)
        case "SGD":
            return self.fractionFormatter(maxFractionDigit: 2) + " SGD"
        case "JPY":
            return "¥" + self.fractionFormatter(maxFractionDigit: 0)
        case "USD":
            return "$" + self.fractionFormatter(maxFractionDigit: 2)
        case "THB":
            return "฿" +  self.fractionFormatter(maxFractionDigit: 0)
        case "IDR":
            return "Rp " + self.fractionFormatter(maxFractionDigit: 0)
        case "PHP":
            return "₱ " + self.fractionFormatter(maxFractionDigit: 2)
        case "INR":
            return "₹ " + self.fractionFormatter(maxFractionDigit: 0)
        case "CLP":
            return "$" + self.fractionFormatter(maxFractionDigit: 0)
        case "MMK":
            return  self.fractionFormatter(maxFractionDigit: 0) + "Ks"
        case "GBP":
            return "£" + self.fractionFormatter(maxFractionDigit: 2)
        case "AED":
            return "AED " + self.fractionFormatter(maxFractionDigit: 2)
        case "SAR":
            return "SAR " + self.fractionFormatter(maxFractionDigit: 2)
        case "LBP":
            return "£L" + self.fractionFormatter(maxFractionDigit: 2)
        case "VND":
            return self.fractionFormatter(maxFractionDigit: 0) + "₫"
        case "AUD":
            return "$" + self.fractionFormatter(maxFractionDigit: 2)
        case "MYR":
            return "RM " + self.fractionFormatter(maxFractionDigit: 2)
        case "CAD":
            return "$" + self.fractionFormatter(maxFractionDigit: 2)
        case "HKD":
            return "HK$" + self.fractionFormatter(maxFractionDigit: 2)
        case "NZD":
            return "$" + self.fractionFormatter(maxFractionDigit: 2)
        case "TWD":
            return "$" + self.fractionFormatter(maxFractionDigit: 2)
        case "KRW":
            return self.fractionFormatter(maxFractionDigit: 0) + "원"
        case "PEN":
            return "S/" + self.fractionFormatter(maxFractionDigit: 2)
        case "BRL":
            return "R$" + self.fractionFormatter(maxFractionDigit: 2)
        case "RUB":
            return "₽" + self.fractionFormatter(maxFractionDigit: 2)
        case "TRY":
            return "₺" + self.fractionFormatter(maxFractionDigit: 2)
        default: // + "MXN", "COP", "ARS"
            return self.fractionFormatter(maxFractionDigit: 2, locale: .current)
        }
    }
    
    func fractionFormatter(maxFractionDigit : Int, locale : Locale? = nil) -> String {
        let nf = NumberFormatter()
        nf.groupingSeparator = ","
        nf.groupingSize = 3
        nf.usesGroupingSeparator = true
        nf.decimalSeparator = "."
        nf.numberStyle = .decimal
        nf.maximumFractionDigits = maxFractionDigit
        nf.minimumFractionDigits = maxFractionDigit
        if let locale = locale {
            nf.locale = locale
        }
        return nf.string(from: self as NSNumber) ?? "0"
    }
    
    func dropFractionIfPossible() -> String {
        if Double(Int(self)) == self {
            return "\(Int(self))"
        }
        else {
            return "\(self)"
        }
        
    }
}
