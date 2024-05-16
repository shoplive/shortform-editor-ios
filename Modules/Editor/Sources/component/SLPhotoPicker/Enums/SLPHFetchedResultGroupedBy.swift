//
//  SLPHFetchedResultGroupedBy.swift
//  CustomImagePicker
//
//  Created by sangmin han on 5/3/24.
//

import Foundation


public enum SLPHFetchedResultGroupedBy {
    case year
    case month
    case week
    case day
    case hour
    case custom(dateFormat: String)
    var dateFormat: String {
        switch self {
        case .year:
            return "yyyy"
        case .month:
            return "yyyyMM"
        case .week:
            return "yyyyMMW"
        case .day:
            return "yyyyMMdd"
        case .hour:
            return "yyyyMMddHH"
        case let .custom(dateFormat):
            return dateFormat
        }
    }
}
