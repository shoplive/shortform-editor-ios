// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ShopLiveShortformEditorSDK",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ShopLiveShortformEditorSDK",
            targets: ["ShopLiveShortformEditorSDK"]),
        .library(
            name: "ShopliveFilterSDK",
            targets: ["ShopliveFilterSDK"]),
    ],
    targets: [
        .binaryTarget(name: "ShopLiveShortformEditorSDK",
                      path: "./Frameworks/ShopLiveShortformEditorSDK.xcframework"),
        .binaryTarget(name: "ShopliveFilterSDK",
                      path: "./Frameworks/ShopliveFilterSDK.xcframework")
    ]
)
