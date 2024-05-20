//
//  Project + Extension.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 5/20/24.
//

import Foundation


public enum ENV {
    public static var GENTYP : String {
        return ProcessInfo.processInfo.environment["TUIST_GENTYPE"] ?? ""
    }
}
