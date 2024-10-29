//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 2/8/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let deployTarget = Target.target(name: "ShopliveSDKCommon",
                                 destinations: .iOS,
                                 product: .framework,
                                 bundleId: "cloud.shoplive.matrix-common-ios",
                                 deploymentTargets: .iOS("11.0"),
                                 infoPlist: .extendingDefault(with: [:]),
                                 sources: ["Sources/**"],
                                 resources: ["Resources/**"],
                                 dependencies: [
                                 ])

let project = Project.makeModule(name: "ShopliveSDKCommon",
                                 targets: [deployTarget])

