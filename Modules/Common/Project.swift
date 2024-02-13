//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 2/8/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let deployTarget = Target(name: "ShopLiveSDKCommon",
                          platform: .iOS,
                          product: .framework,
                          bundleId: "com.app" + ".shoplive.common.sdk",
                          deploymentTarget: .iOS(targetVersion: "11.0", devices: .iphone),
                          infoPlist: .extendingDefault(with: [:]),
                          sources: ["Sources/**"],
                          resources: nil,
                          dependencies: [
                          ])

let project = Project.makeModule(name: "ShopLiveSDKCommon",
                                 targets: [deployTarget])

