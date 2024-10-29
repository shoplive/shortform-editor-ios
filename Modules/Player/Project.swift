//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 2/8/24.
//

import Foundation
import ProjectDescription
import ProjectDescriptionHelpers
///infoPlist: .extendingDefault(with: [:]),

let deployTarget = Target.target(name: "ShopLiveSDK",
                                 destinations: .iOS,
                                 product: .framework,
                                 bundleId: "cloud.shoplive.sdk",
                                 deploymentTargets: .iOS("11.0"),
                                 infoPlist: .extendingDefault(with: [:]),
                                 sources: ["Sources/**"],
                                 resources: ["Resources/**"],
                                 dependencies: [
                                    .project(target: "ShopliveSDKCommon",
                                             path: .relativeToRoot("Modules/Common"))
                                 ])

let project = Project.makeModule(name: "ShopLiveSDK",
                                 targets: [deployTarget])

