//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 2/8/24.
//

import ProjectDescription
import ProjectDescriptionHelpers


let demoTarget = Target(name: "ShopLivePlayerDemo",
                        platform: .iOS,
                        product: .app,
                        bundleId: "com.app" + ".player.demo",
                        deploymentTarget: .iOS(targetVersion: "12.0", devices: .iphone),
                        infoPlist: .file(path: "Support/Info.plist"),
                        sources: ["Sources/**"],
                        resources: ["Resources/**"],
                        dependencies: [
                            .project(target: "DropDownSDK", path: .relativeToRoot("Modules/DropDown")),
                            .project(target: "ShopLiveSDK", path: .relativeToRoot("Modules/Player")),
                            .project(target: "ShopLiveSDKCommon",
                                     path: .relativeToRoot("Modules/Common")),
                            .external(name: "SideMenu"),
                            .external(name: "Toast"),
                            .external(name: "SwiftyJWT"),
                            .external(name: "CryptoSwift")
                        ])



let project = Project.makeModule(name: "ShopLivePlayerDemo",
                                 targets: [demoTarget])
