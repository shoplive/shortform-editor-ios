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

let deployTarget = Target(name: "ShopLiveSDK",
                          platform: .iOS,
                          product: .framework,
                          bundleId: "com.app" + ".shoplive.player.sdk",
                          deploymentTarget: .iOS(targetVersion: "11.0", devices: .iphone),
                          infoPlist: .extendingDefault(with: [:]),
                          sources: ["Sources/**"],
                          resources: nil,
                          dependencies: [
                            
                            .project(target: "ShopLiveSDKCommon",
                                     path: .relativeToRoot("Modules/Common"))
                          ])

let project = Project.makeModule(name: "ShopLiveSDK",
                                 targets: [deployTarget])

