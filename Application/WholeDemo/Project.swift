//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 2/8/24.
//

import ProjectDescription
import ProjectDescriptionHelpers


let demoTarget = Target(name: "ShopLiveDemo",
                        platform: .iOS,
                        product: .app,
                        bundleId: "com.app" + ".shoplive.whole.demo",
                        deploymentTarget: .iOS(targetVersion: "12.0", devices: .iphone),
                        infoPlist: .extendingDefault(with: [:]),
                        sources: ["Sources/**"],
                        resources: nil,
                        dependencies: [
                            .project(target: "ShopLiveShortformSDK", path: .relativeToRoot("Modules/Shortform")),
                            .project(target: "ShopLiveSDK", path: .relativeToRoot("Modules/Player")),
                            .project(target: "ShopLiveSDKCommon",
                                     path: .relativeToRoot("Modules/Common"))
                        ])



let project = Project.makeModule(name: "ShopLiveDemo",
                                 targets: [demoTarget])


