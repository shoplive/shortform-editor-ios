//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 2/8/24.
//

import ProjectDescription
import ProjectDescriptionHelpers


let demoTarget = Target.target(name: "ShopLiveDemo",
                               destinations: .iOS,
                               product: .app,
                               bundleId: "com.app" + ".shoplive.whole.demo",
                               deploymentTargets: .iOS("12.0"),
                               infoPlist: .extendingDefault(with: [:]),
                               sources: ["Sources/**"],
                               resources: nil,
                               dependencies: [
                                .project(target: "ShopLiveShortformSDK", path: .relativeToRoot("Modules/Shortform")),
                                .project(target: "ShopLiveSDK", path: .relativeToRoot("Modules/Player")),
                                .project(target: "ShopliveSDKCommon",
                                         path: .relativeToRoot("Modules/Common")),
                                .project(target: "ShopLiveShortformEditorSDK", path: .relativeToRoot("Modules/Editor"))
                               ])



let project = Project.makeModule(name: "ShopLiveDemo",
                                 targets: [demoTarget])


