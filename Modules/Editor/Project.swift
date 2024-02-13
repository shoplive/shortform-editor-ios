//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 2/8/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let deployTarget = Target(name: "ShopLiveShortformEditorSDK",
                          platform: .iOS,
                          product: .staticFramework,
                          bundleId: "com.app" + ".shoplive.shortform.editor.sdk",
                          deploymentTarget: .iOS(targetVersion: "12.0", devices: .iphone),
                          infoPlist: .extendingDefault(with: [:]),
                          sources: ["Sources/**"],
                          resources: ["Resources/**"],
                          dependencies: [
                            .project(target: "ShopLiveSDKCommon",
                                     path: .relativeToRoot("Modules/Common"))
                          ])

let project = Project.makeModule(name: "ShopLiveShortformEditorSDK",
                                 targets: [deployTarget])
