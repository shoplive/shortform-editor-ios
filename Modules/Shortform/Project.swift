//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 2/8/24.
//

import ProjectDescription
import ProjectDescriptionHelpers


let deployTarget = Target(name: "ShopLiveShortformSDK",
                          platform: .iOS,
                          product: .staticFramework,
                          bundleId: "com.app" + ".shoplive.shortform.sdk",
                          deploymentTarget: .iOS(targetVersion: "11.0", devices: .iphone),
                          infoPlist: .extendingDefault(with: [:]),
                          sources: ["Sources/**"],
                          resources: nil,
                          dependencies: [
                            .project(target: "ShopLiveSDKCommon",
                                     path: .relativeToRoot("Modules/Common"))
                          ])

let project = Project.makeModule(name: "ShopLiveShortformSDK",
                                 targets: [deployTarget])







