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
      .remote(url: "https://github.com/jonkykong/SideMenu.git", requirement: .upToNextMajor(from: "6.0.0") ),
      .remote(url: "https://github.com/scalessec/Toast-Swift.git", requirement: .upToNextMajor(from: "5.0.0")),
      .remote(url: "https://github.com/polarcop/SwiftyJWT.git", requirement: .upToNextMajor(from: "1.0.0")),
      .remote(url: "https://github.com/krzyzanowskim/CryptoSwift.git", requirement: .upToNextMajor(from: "1.8.2")),//.branch("main")
      .remote(url: "https://github.com/firebase/firebase-ios-sdk.git", requirement: .upToNextMajor(from: "8.0.0")),
      .remote(url: "https://github.com/SnapKit/SnapKit.git", requirement: .upToNextMajor(from: "5.0.0")),
      .remote(url: "https://github.com/rechsteiner/Parchment", requirement: .upToNextMajor(from: "3.2.1")),
      .remote(url: "https://github.com/jriosdev/iOSDropDown.git", requirement: .upToNextMajor(from: "0.4.0")),
      .remote(url: "https://github.com/hackiftekhar/IQKeyboardManager.git", requirement: .upToNextMajor(from: "7.0.2"))
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
