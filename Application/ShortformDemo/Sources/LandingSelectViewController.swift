//
//  LandingSelectViewController.swift
//  shortform-dev-examples
//
//  Created by 김우현 on 4/14/23.
//

import UIKit
import ShopLiveShortformSDK

protocol LandingSelectProtocol: AnyObject {
    func didChangedLanding()
}

enum LandingInfo {
    case dev
    case stage
    case qa
    case real
    
    var accessKey: String {
        switch self {
        case .dev:
            return "a1AW6QRCXeoZ9MEWRdDQ"
        case .stage:
            return "53Q8PFmSRe7xyRNy5wUS"
        case .qa:
            return "e4cscSXMMHtEQnMiZI5E"
        case .real:
            //                return "t74qFnUhFYweMpSlBPf8"//신성통상 키
            return "FRBrbbIsNLGNcRWvGGTb"
        }
    }
}
