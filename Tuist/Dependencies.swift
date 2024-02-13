//
//  Dependencies.swift
//  Config
//
//  Created by sangmin han on 2/13/24.
//

import ProjectDescription
import ProjectDescriptionHelpers


//    .remote(url: "https://github.com/AssistoLab/DropDown.git",
//            requirement: .branch("master")),

let dependencies = Dependencies(
  carthage: nil,
  swiftPackageManager: SwiftPackageManagerDependencies(
    [
      .remote(
        url: "https://github.com/jonkykong/SideMenu.git",
        requirement: .upToNextMajor(from: "6.0.0")
      ),
      .remote(url: "https://github.com/scalessec/Toast-Swift.git",
              requirement: .upToNextMajor(from: "5.0.0")),
      .remote(url: "https://github.com/polarcop/SwiftyJWT.git",
              requirement: .upToNextMajor(from: "1.0.0")),
      .remote(url: "https://github.com/krzyzanowskim/CryptoSwift.git",
              requirement: .branch("main"))
      
    ],
    productTypes: [ : ],
    baseSettings: .settings(
      configurations: [
        .debug(name: .debug),
        .release(name: .release),
      ]
    ),
    targetSettings: [:]
  ),
  platforms: [.iOS]
)
