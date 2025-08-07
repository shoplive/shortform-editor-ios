//
//  Project.swift
//  CommonManifests
//
//  Created by yong C on 8/6/25.
//

import ProjectDescription
import ProjectDescriptionHelpers

let moduleTarget = Target.target(
  name: "OnlyDomesticModule",
  destinations: .iOS,
  product: .framework, // 또는 .framework
  bundleId: "cloud.shoplive.sdk.onlyModule",
  deploymentTargets: .iOS("11.0"),
  infoPlist: .default, // Info.plist 파일 불필요할 경우
  sources: [],
  resources: [],
  dependencies: [
    .project(target: "ShopLiveSDK", path: .relativeToRoot("Modules/Player")),
    .project(target: "ShopliveSDKCommon", path: .relativeToRoot("Modules/Common"))
  ]
)

let project = Project.makeModule(
    name: "OnlyDomesticModule",
    configurations: [
        .debug(name: .debug, xcconfig: .relativeToRoot("XCConfigs/ConversionTrackingDemo.xcconfig")),
        .release(name: .release, xcconfig: .relativeToRoot("XCConfigs/ConversionTrackingDemo.xcconfig")
                )
    ],
    targets: [moduleTarget]
)
