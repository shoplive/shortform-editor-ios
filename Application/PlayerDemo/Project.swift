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
                        bundleId: "cloud.shoplive.sdk.swiftdemo.qa.SwiftDemo",
                        deploymentTarget: .iOS(targetVersion: "12.0", devices: .iphone),
                        infoPlist: .file(path: "Support/Info.plist"),
                        sources: ["Sources/**","../../XCConfigs/version.xcconfig"],
                        resources: ["Resources/**"],
                        dependencies: [
                            .project(target: "ShopLiveSDK", path: .relativeToRoot("Modules/Player")),
                            .project(target: "ShopliveSDKCommon", path: .relativeToRoot("Modules/Common")),
                            .external(name: "SideMenu"),
                            .external(name: "Toast"),
                            .external(name: "SwiftyJWT"),
                            .external(name: "CryptoSwift"),
                            .external(name: "iOSDropDown")
                        ])


let project = Project.makeModule(name: "ShopLivePlayerDemo",
                                 configurations: [
                                    .debug(name: .debug, xcconfig: .relativeToRoot("XCConfigs/PlayerDemoConfig.xcconfig")),
                                    .release(name: .release, xcconfig: .relativeToRoot("XCConfigs/PlayerDemoConfig.xcconfig"))
                                 ],
                                 targets: [demoTarget])

