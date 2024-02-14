//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 2/8/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let deployTarget = Target(name: "ShopliveSDKCommon",
                          platform: .iOS,
                          product: .framework,
                          bundleId: "cloud.shoplive.matrix-common-ios",
                          deploymentTarget: .iOS(targetVersion: "11.0", devices: .iphone),
                          infoPlist: .extendingDefault(with: [:]),
                          sources: ["Sources/**"],
                          resources: nil,
                          dependencies: [
                          ])

let project = Project.makeModule(name: "ShopliveSDKCommon",
                                 targets: [deployTarget])

