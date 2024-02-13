//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 2/13/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let deployTarget = Target(name: "DropDownSDK",
                          platform: .iOS,
                          product: .framework,
                          bundleId: "com.app" + ".shoplive.dropDown.sdk",
                          deploymentTarget: .iOS(targetVersion: "11.0", devices: .iphone),
                          infoPlist: .extendingDefault(with: [:]),
                          sources: ["Sources/**"],
                          resources: ["Resources/**"],
                          dependencies: [
                          ])

let project = Project.makeModule(name: "DropDownSDK",
                                 targets: [deployTarget])


