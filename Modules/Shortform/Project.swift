//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 2/8/24.
//

import ProjectDescription
import ProjectDescriptionHelpers


let deployTarget = Target.target(name: "ShopLiveShortformSDK",
                                 destinations: .iOS,
                                 product: .framework,
                                 bundleId: "cloud.shoplive.matrix-shortform-ios",
                                 deploymentTargets: .iOS("11.0"),
                                 infoPlist: .extendingDefault(with: [:]),
                                 sources: ["Sources/**"],
                                 resources: ["Resources/**"],
                                 dependencies: [
                                    .project(target: "ShopliveSDKCommon",
                                             path: .relativeToRoot("Modules/Common"))
                                 ])

let project = Project.makeModule(name: "ShopLiveShortformSDK",
                                 targets: [deployTarget])







