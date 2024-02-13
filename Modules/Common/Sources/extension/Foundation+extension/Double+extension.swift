//
//  Double+extension.swift
//  ShopliveCommonLibrary
//
//  Created by James Kim on 11/24/22.
//

import Foundation

public extension Double {
    func formattedString_SL(by format: String) -> String {
        var fromDate: Double = self
        if self.numberOfDigit_SL > 10 {
            fromDate = Double(self / pow(10, Double(self.numberOfDigit_SL - 10)))
        }

        let date = Date(timeIntervalSince1970: fromDate)

        let dmf = DateFormatter()
        dmf.timeZone = .current
        dmf.locale = Locale(identifier: Locale.current.identifier)
        dmf.timeZone = TimeZone(identifier: TimeZone.current.identifier)
        dmf.dateFormat = format
        return dmf.string(from: date)
    }

    var validDateFromTimestamp_SL: Bool {
        var fromTimestamp: Double = self
        if self.numberOfDigit_SL > 10 {
            fromTimestamp = Double(self / pow(10, Double(self.numberOfDigit_SL - 10)))
        }
        
        let toDate = Date()
        let fromDate = Date(timeIntervalSince1970: fromTimestamp)
        let standardDate = Date(timeIntervalSince1970: 0)
        
        guard fromDate.timeIntervalSince1970 >= standardDate.timeIntervalSince1970 else {
            return false
        }
        
        guard fromDate.timeIntervalSince1970 < toDate.timeIntervalSince1970 else {
            return false
        }
        
        return true
    }
    
    func elapsedTimeString_SL() -> String {
        let toDate = Date()
        
        var fromTimestamp: Double = self
        if self.numberOfDigit_SL > 10 {
            fromTimestamp = Double(self / pow(10, Double(self.numberOfDigit_SL - 10)))
        }
        
        let fromDate = Date(timeIntervalSince1970: fromTimestamp)
        let standardDate = Date(timeIntervalSince1970: 0)
        
        guard fromDate.timeIntervalSince1970 >= standardDate.timeIntervalSince1970 else {
            return ""
        }
        
        guard fromDate.timeIntervalSince1970 < toDate.timeIntervalSince1970 else {
            return ""
        }
        
        let difference = NSCalendar.current.dateComponents([.hour, .minute, .second], from: fromDate, to: toDate)

        let elapsedTime: String = ((difference.hour ?? 0 > 0) ? String(format: "%02d:", difference.hour!) : "") + ((difference.minute ?? 0 > 0) ? String(format: "%02d:", difference.minute!) : "00:") + ((difference.second ?? 0 > 0) ? String(format: "%02d", difference.second!) : "00")

        return elapsedTime
    }
    
    func elapsedTimeString_SL(with date: Date) -> String {
        
        var fromDate: Double = self

        if self.numberOfDigit_SL > 10 {
            fromDate = Double(self / pow(10, Double(self.numberOfDigit_SL - 10)))
        }

        let dateFrom = Date(timeIntervalSince1970: fromDate)
        let dateTo = date

        guard dateFrom.timeIntervalSince1970 < dateTo.timeIntervalSince1970 else {
            return ""
        }

        let difference = NSCalendar.current.dateComponents([.hour, .minute, .second], from: dateFrom, to: dateTo)

        let elapsedTime: String = ((difference.hour ?? 0 > 0) ? String(format: "%02d:", difference.hour!) : "") + ((difference.minute ?? 0 > 0) ? String(format: "%02d:", difference.minute!) : "00:") + ((difference.second ?? 0 > 0) ? String(format: "%02d", difference.second!) : "00")

        return elapsedTime
    }

    var numberOfDigit_SL: Int {
        guard let str: String = .init("\(Int(self))") else { return 0 }
        return str.count
    }

    
}
