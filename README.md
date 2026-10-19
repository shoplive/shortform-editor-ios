# iOS ShopLiveShortformEditor SDK

숏폼 에디터(`ShopLiveShortformEditorSDK`)와 필터(`ShopliveFilterSDK`).

## 요구사항

- iOS 15 이상 (1.9.0 부터. Common 1.9.0 기준)

## 버전 호환

| 에디터 | Common | 숏폼 | 라이브 SDK |
|---|---|---|---|
| **1.9.0** | 1.9.0 (`shoplive/common-ios`) | 1.9.0 | 1.x(`shoplive-sdk-ios` 1.9.1~) · 3.x(3.0.3~) 모두 |
| 1.8.13 | ≤ 1.8.14 | 1.8.13 | ShopLive ≤ 1.8.14 |

> ⚠️ 에디터 1.8.13 은 Common 1.8.15 이상(1.9.0 포함)과 함께 쓸 수 없습니다(실행 즉시 `Symbol not found`).

## Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/shoplive/shortform-editor-ios", exact: "1.9.0")
    // Common(shoplive/common-ios 1.9.0)과 ffmpeg-kit(shoplive/ffmpeg-kit-spm 5.1.3)을 의존으로 함께 가져옵니다.
]
```

## CocoaPods

```ruby
source 'https://cdn.cocoapods.org/'
source 'https://github.com/shoplive/pod-specs.git'

pod 'ShopLiveShortformEditorSDK', '1.9.0'   # ShopliveSDKCommon 1.9.0 을 의존으로 가져옵니다
```

ffmpeg-kit 은 CocoaPods trunk 에서 내려가 pod 의존으로 선언할 수 없습니다. CocoaPods 로 설치하는 앱은
`ffmpegkit` · `libavcodec` · `libavdevice` · `libavfilter` · `libavformat` · `libavutil` xcframework 를
[shoplive/ffmpeg-kit-spm](https://github.com/shoplive/ffmpeg-kit-spm) 릴리스(v5.1.3)에서 받아 앱에 포함해야 합니다.
