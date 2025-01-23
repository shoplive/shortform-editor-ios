//
//  Package.swift
//  matrix-sdk-iosManifests
//
//  Created by sangmin han on 10/29/24.
//
// swift-tools-version: 6.0
@preconcurrency import PackageDescription

#if TUIST
import ProjectDescription
import ProjectDescriptionHelpers

let packageSettings = PackageSettings(baseSettings: .settings(configurations: [
    .debug(name: .debug),
    .debug(name: .configuration("QA")),
    .release(name: .configuration("QA")),
    .release(name: .release)
]))

#endif

let package = Package(
    name: "PackageName",
    dependencies: [
        .package(url: "https://github.com/jonkykong/SideMenu.git",  .upToNextMajor(from: "6.0.0") ),
        .package(url: "https://github.com/scalessec/Toast-Swift.git",  .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift.git",  .upToNextMajor(from: "1.8.2")),//.branch("main")
        .package(url: "https://github.com/firebase/firebase-ios-sdk.git",  .upToNextMajor(from: "8.0.0")),
        .package(url: "https://github.com/SnapKit/SnapKit.git",  .upToNextMajor(from: "5.0.0")),
        .package(url: "https://github.com/rechsteiner/Parchment",  .upToNextMajor(from: "3.2.1")),
        .package(url: "https://github.com/jriosdev/iOSDropDown.git",  .upToNextMajor(from: "0.4.0")),
        .package(url: "https://github.com/hackiftekhar/IQKeyboardManager.git",  .upToNextMajor(from: "7.0.2")),
            .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.4.3")),
        .package(url: "https://github.com/slackhq/PanModal.git",  .upToNextMajor(from: "1.0.0")),
        .package(url: "https://github.com/ReactorKit/ReactorKit.git",  .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/ReactiveX/RxSwift.git",  .upToNextMajor(from: "6.0.0")),
        .package(url: "https://github.com/malcommac/SwiftDate.git",  .upToNextMajor(from: "6.3.1")),
        .package(url: "https://github.com/malcommac/SwiftRichString.git",  .upToNextMajor(from: "3.0.0")),
        .package(url: "https://github.com/devxoul/Then.git",  .upToNextMajor(from: "2.7.0")),
        .package(url: "https://github.com/scalessec/Toast-Swift.git",  .upToNextMajor(from: "5.0.0")),
        //.package(url: "https://github.com/polarcop/SwiftyJWT.git",  .upToNextMajor(from: "1.0.0")),
        //      .remote(url: "https://github.com/ashleymills/Reachability.swift", requirement: .branch("master")),
        .package(url: "https://github.com/RxSwiftCommunity/RxGesture.git",  .upToNextMajor(from: "4.0.0")),
        .package(url: "https://github.com/onevcat/Kingfisher.git",  .upToNextMajor(from: "7.0.0"))
    ]
)
