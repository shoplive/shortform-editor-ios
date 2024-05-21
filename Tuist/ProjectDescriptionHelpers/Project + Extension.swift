//
//  Project + Extension.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 5/20/24.
//

import Foundation
import ProjectDescription

public enum ENV {
    public static var GENTYPE : String {
        return ProcessInfo.processInfo.environment["TUIST_GENTYPE"] ?? ""
    }
}


