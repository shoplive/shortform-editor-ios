//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 2/8/24.
//

import ProjectDescription
import ProjectDescriptionHelpers

let demoTarget = Target(name: "ShortformDemo",
                        platform: .iOS,
                        product: .app,
                        bundleId: "cloud.shoplive.dev.shortform-examples",
                        deploymentTarget: .iOS(targetVersion: "12.0", devices: .iphone),
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
                                 targets: [demoTarget]
                                 ,headerSearchPaths: ["HEADER_SEARCH_PATHS" : "$(SRCROOT)/Sources/Editor/EOExportUI/Utils $(SRCROOT)/Sources/Editor/EOExportUI/View $(SRCROOT)/Sources/Editor/EOExportUI/ViewController",
                                                      "SWIFT_OBJC_BRIDGING_HEADER" : "$(SRCROOT)/Sources/ShortformDemo-Bridging-Header.h"])

