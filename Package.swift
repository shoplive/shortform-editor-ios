// swift-tools-version: 5.9
// ShopLiveShortformEditorSDK · ShopliveFilterSDK — Shoplive iOS 숏폼 에디터 배포 매니페스트.
//
// 에디터는 런타임에 다음을 링크한다. 이제 이 매니페스트가 의존으로 선언한다.
//   - Common(ShopliveSDKCommon · ShopliveAPI) — shoplive/common-ios (라이브 SDK 1.x · 숏폼과 같은 패키지를 공유)
//   - ffmpegkit · libavcodec/avdevice/avfilter/avformat/avutil · libswresample/libswscale — shoplive/ffmpeg-kit-spm
//   - ShopliveFilterSDK — 이 패키지의 필터 바이너리(에디터 product 에 함께 포함)

import PackageDescription

let commonVersion = "1.9.0"

let package = Package(
    name: "ShopLiveShortformEditorSDK",
    platforms: [
        // Common 1.9.0 바이너리 기준
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "ShopLiveShortformEditorSDK",
            // 에디터는 필터 모듈을 링크하므로 에디터 product 만 추가해도 ShopliveFilterSDK 가 함께 포함되게 한다.
            targets: ["ShopLiveShortformEditorSDK", "ShopliveFilterSDK", "ShopLiveShortformEditorSDKDependencies"]
        ),
        .library(
            name: "ShopliveFilterSDK",
            targets: ["ShopliveFilterSDK"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/shoplive/common-ios", exact: Version(stringLiteral: commonVersion)),
        .package(url: "https://github.com/shoplive/ffmpeg-kit-spm", exact: "5.1.3")
    ],
    targets: [
        .binaryTarget(
            name: "ShopLiveShortformEditorSDK",
            path: "./Frameworks/ShopLiveShortformEditorSDK.xcframework"
        ),
        .binaryTarget(
            name: "ShopliveFilterSDK",
            path: "./Frameworks/ShopliveFilterSDK.xcframework"
        ),
        // 링크 전용 — binaryTarget 은 다른 패키지 product 에 의존할 수 없어 이 타깃이 Common · ffmpeg 를 끌어온다.
        .target(
            name: "ShopLiveShortformEditorSDKDependencies",
            dependencies: [
                .product(name: "ShopliveSDKCommon", package: "common-ios"),
                .product(name: "FFmpeg-Kit", package: "ffmpeg-kit-spm")
            ],
            path: "Sources/ShopLiveShortformEditorSDKDependencies"
        )
    ]
)
