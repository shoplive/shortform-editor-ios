//
//  Project.swift
//  CommonManifests
//
//  Created by Tabber on 1/17/25.
//

import ProjectDescription
import ProjectDescriptionHelpers


let name: String = "PlayerDemo2"
let bundleId: String = "cloud.shoplive.sdk.swiftdemo.qa.SwiftDemo2"

let demoTarget = Target.target(name: name,
                               destinations: .iOS,
                               product: .app,
                               bundleId: "cloud.shoplive.sdk.swiftdemo.qa.SwiftDemo2",
                               deploymentTargets: .iOS("13.0"),
                               infoPlist: .file(path: "Support/Info.plist"),
                               sources: ["Sources/**","../../XCConfigs/version.xcconfig"],
                               resources: ["Resources/**"],
                               dependencies: [
                                .project(target: "ShopLiveSDK", path: .relativeToRoot("Modules/Player")),
                                .project(target: "ShopliveSDKCommon", path: .relativeToRoot("Modules/Common")),
                                .external(name: "SideMenu"),
                                .external(name: "Toast"),
                                .external(name: "CryptoSwift"),
                                .external(name: "iOSDropDown"),
                                .external(name: "SnapKit")
                               ])

let demoTestTarget = Target.target(name: "\(name)Tests",
                                   destinations: .iOS,
                                   product: .unitTests,
                                   bundleId: "\(bundleId)Tests",
                                   deploymentTargets: .iOS("13.0"),
                                   infoPlist: .default,
                                   sources: "Tests/**",
                                   dependencies: [.target(name: name)]
)


let project = Project.makeModule(name: "PlayerDemo2",
                                 configurations: [
                                    .debug(name: .debug, xcconfig: .relativeToRoot("XCConfigs/PlayerDemoConfig.xcconfig")),
                                    .release(name: .release, xcconfig: .relativeToRoot("XCConfigs/PlayerDemoConfig.xcconfig"))
                                 ],
                                 targets: [demoTarget, demoTestTarget])
