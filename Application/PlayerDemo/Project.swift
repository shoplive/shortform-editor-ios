//
//  Project.swift
//  ProjectDescriptionHelpers
//
//  Created by sangmin han on 2/8/24.
//

import ProjectDescription
import ProjectDescriptionHelpers


let demoTarget = Target.target(name: "PlayerDemo",
                               destinations: .iOS,
                               product: .app,
                               bundleId: "cloud.shoplive.sdk.swiftdemo.qa.SwiftDemo",
                               deploymentTargets: .iOS("13.0"),
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


let project = Project.makeModule(name: "PlayerDemo",
                                 configurations: [
                                    .debug(name: .debug, xcconfig: .relativeToRoot("XCConfigs/PlayerDemoConfig.xcconfig")),
                                    .release(name: .release, xcconfig: .relativeToRoot("XCConfigs/PlayerDemoConfig.xcconfig"))
                                 ],
                                 targets: [demoTarget])

