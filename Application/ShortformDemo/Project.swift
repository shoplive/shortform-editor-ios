//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 2/8/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let demoTarget = Target.target(name: "ShortformDemo",
                               destinations: .iOS,
                               product: .app,
                               bundleId: "cloud.shoplive.dev.shortform-examples",
                               deploymentTargets: .iOS("13.0"),
                               infoPlist: .file(path: "Support/Info.plist"),
                               sources: ["Sources/**"],
                               resources: ["Resources/**"],
                               dependencies: [
                                .project(target: "ShopLiveShortformSDK", path: .relativeToRoot("Modules/Shortform")),
                                .project(target: "ShopLiveShortformEditorSDK", path: .relativeToRoot("Modules/Editor")),
                                .project(target: "ShopliveSDKCommon", path: .relativeToRoot("Modules/Common")),
                                .external(name: "SnapKit"),
                                .external(name: "Parchment"),
                                .external(name: "FirebaseAnalytics"),
                                .external(name: "FirebaseCrashlytics"),
                                .external(name: "FirebaseDynamicLinks"),
                                .external(name: "Toast")
                               ])

let project = Project.makeModule(name: "ShortformDemo",
                                 configurations: [
                                    .debug(name: .debug, xcconfig: .relativeToRoot("XCConfigs/ShortformDemoConfig.xcconfig")),
                                    .release(name: .release, xcconfig: .relativeToRoot("XCConfigs/ShortformDemoConfig.xcconfig"))
                                 ],
                                 targets: [demoTarget])
