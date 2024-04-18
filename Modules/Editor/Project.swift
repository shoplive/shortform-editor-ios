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
                          product: .framework,
                          bundleId: "com.app.matrix-shortform-editor-ios",
                          deploymentTarget: .iOS(targetVersion: "12.0", devices: .iphone),
                          infoPlist: .extendingDefault(with: [:]),
                          sources: ["Sources/**"],
                          resources: ["Resources/**"],
                          dependencies: [
                            .project(target: "ShopliveSDKCommon", path: .relativeToRoot("Modules/Common")),
                            .xcframework(path: .relativeToRoot("Modules/Editor/Framework/ffmpegkit.xcframework")),
                            .xcframework(path: .relativeToRoot("Modules/Editor/Framework/libavcodec.xcframework")),
                            .xcframework(path: .relativeToRoot("Modules/Editor/Framework/libavdevice.xcframework")),
                            .xcframework(path: .relativeToRoot("Modules/Editor/Framework/libavfilter.xcframework")),
                            .xcframework(path: .relativeToRoot("Modules/Editor/Framework/libavformat.xcframework")),
                            .xcframework(path: .relativeToRoot("Modules/Editor/Framework/libswresample.xcframework")),
                            .xcframework(path: .relativeToRoot("Modules/Editor/Framework/libswscale.xcframework")),
                            .xcframework(path: .relativeToRoot("Modules/Editor/Framework/libavutil.xcframework")),
                            .xcframework(path: .relativeToRoot("Modules/Editor/Framework/ShopliveFilterSDK.xcframework"))
                          ])

let project = Project.makeModule(name: "ShopLiveShortformEditorSDK",
                                 targets: [deployTarget])

//["HEADER_SEARCH_PATHS" : "$(SRCROOT)/Sources/BytePlus/EOExportUI/Utils $(SRCROOT)/Sources/BytePlus/EOExportUI/View $(SRCROOT)/Sources/BytePlus/EOExportUI/ViewController", "SWIFT_OBJC_BRIDGING_HEADER" : "$(SRCROOT)/Sources/BytePlus/ShopLiveShortformEditorSDK-Bridging-Header.h"]
