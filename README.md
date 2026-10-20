# iOS ShopLiveShortformEditor SDK

숏폼 에디터(`ShopLiveShortformEditorSDK`)와 필터(`ShopliveFilterSDK`).

Release notes: [CHANGELOG.md](CHANGELOG.md)

## 요구사항

- iOS 15 이상 (1.9.1 부터. Common 1.9.0 기준)

## 버전 호환

| 에디터 | Common | 숏폼 | 라이브 SDK |
|---|---|---|---|
| **1.9.1** | 1.9.0 (`shoplive/common-ios`) | 1.9.1 | 1.x(SPM: `shoplive-sdk-ios` 1.9.1~, CocoaPods: `ShopLive` 1.9.0~) · 3.x(3.0.3~) 모두 |
| 1.8.13 | ≤ 1.8.14 | 1.8.13 | ShopLive ≤ 1.8.14 |

> ⚠️ 에디터 1.8.13 은 Common 1.8.15 이상(1.9.0 포함)과 함께 쓸 수 없습니다(실행 즉시 `Symbol not found`).

> 라이브 SDK 1.x 의 `1.9.1~` 는 Swift Package Manager 기준입니다(1.9.1 부터 `shoplive-sdk-ios` 가 `common-ios` 를 의존으로 가져옴).
> CocoaPods 로 설치하면 `ShopLive` 1.9.0 도 Common 1.9.0 과 함께 쓸 수 있습니다.

## Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/shoplive/shortform-editor-ios", exact: "1.9.1")
    // Common(shoplive/common-ios 1.9.0)과 ffmpeg-kit(shoplive/ffmpeg-kit-spm 5.1.3)을 의존으로 함께 가져옵니다.
]
```

`ShopLiveShortformEditorSDK` product 하나만 추가하면 됩니다. 필터(`ShopliveFilterSDK`)도 함께 포함됩니다.

### 1.8.x 에서 업데이트하는 경우

종전에는 앱이 `shoplive/ffmpeg-kit-spm` 을 직접 추가해야 했습니다. 1.9.1 부터는 에디터 패키지가
`ffmpeg-kit-spm` 을 `exact: "5.1.3"` 으로 의존하므로, 앱에 직접 추가한 `ffmpeg-kit-spm` 은 제거하거나
같은 `exact: "5.1.3"` 으로 맞추세요. 다른 버전을 지정하면 패키지 해석이 실패합니다.

## CocoaPods

```ruby
source 'https://cdn.cocoapods.org/'
source 'https://github.com/shoplive/pod-specs.git'

pod 'ShopLiveShortformEditorSDK', '1.9.1'   # ShopliveSDKCommon 1.9.0 을 의존으로 가져옵니다
```

ffmpeg-kit 은 CocoaPods trunk 에서 내려가 pod 의존으로 선언할 수 없습니다. CocoaPods 로 설치하는 앱은
아래 8개 xcframework 를 [shoplive/ffmpeg-kit-spm](https://github.com/shoplive/ffmpeg-kit-spm) 릴리스(v5.1.3)에서 받아
앱 타깃에 추가(Embed & Sign)해야 합니다.

`ffmpegkit` · `libavcodec` · `libavdevice` · `libavfilter` · `libavformat` · `libavutil` · `libswresample` · `libswscale`
