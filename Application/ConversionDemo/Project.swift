//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 4/15/24.
//

import ProjectDescription
import ProjectDescriptionHelpers


let demoTarget = Target(name: "ConversionTrackingDemo",
                        platform: .iOS,
                        product: .app,
                        bundleId: "cloud.shoplive.sdk.conversion.tracking.demo",
                        deploymentTarget: .iOS(targetVersion: "13.0", devices: .iphone),
                        infoPlist: .file(path: "Support/Info.plist"),
                        sources: ["Sources/**","../../XCConfigs/version.xcconfig"],
                        resources: ["Resources/**"],
                        dependencies: [
                            .project(target: "ShopliveSDKCommon", path: .relativeToRoot("Modules/Common")),
                            .external(name: "Toast"),
                            .external(name: "iOSDropDown")
                        ])


let project = Project.makeModule(name: "ConversionTrackingDemo",
                                 configurations: [
                                    .debug(name: .debug, xcconfig: .relativeToRoot("XCConfigs/ConversionTrackingDemo.xcconfig")),
                                    .release(name: .release, xcconfig: .relativeToRoot("XCConfigs/ConversionTrackingDemo.xcconfig"))
                                 ],
                                 targets: [demoTarget])


