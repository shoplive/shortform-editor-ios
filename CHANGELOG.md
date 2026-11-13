# Changelog

## 1.9.1

### Requirements

- iOS 15.0 or later.
- Requires ShopliveSDKCommon 1.9.0 (`shoplive/common-ios`). SwiftPM and CocoaPods resolve it automatically.
- Requires ffmpeg-kit 5.1.3.
  - SwiftPM: the package now depends on `shoplive/ffmpeg-kit-spm` `exact: "5.1.3"`. If your app added `ffmpeg-kit-spm` directly, remove it or pin it to the same `exact: "5.1.3"`; any other version fails package resolution.
  - CocoaPods: ffmpeg-kit cannot be declared as a pod dependency. Add the eight xcframeworks from the `shoplive/ffmpeg-kit-spm` v5.1.3 release to your app target (Embed & Sign), as described in the README.
- Use with ShopliveShortformSDK 1.9.1.
- Using with the ShopLive live SDK 1.x: SwiftPM needs `shoplive-sdk-ios` 1.9.1 or later; CocoaPods works with `ShopLive` 1.9.0 or later.
- Editor 1.8.13 does not run with ShopliveSDKCommon 1.8.15 or later (including 1.9.0). Update the Editor and Shortform to 1.9.1 together.

### Added

- `ShopLiveShortformEditorAspectRatio` — one crop (aspect ratio) option type shared by the shortform editor and the video editor configurations.
- `ShopLiveShortformEditorTrimOption` — one trim (duration, in seconds) option type shared by both configurations.
- `ShopLiveShortformEditorVideoOutputOption` — output option (typo-free name) with `init(videoOutputQuality:videoOutputResolution:)`.

### Changed

- SwiftPM: the `ShopLiveShortformEditorSDK` product now includes the filter module (`ShopliveFilterSDK`). Adding the editor product alone is enough.
- Defaults (unchanged on iOS, now documented and aligned across platforms): aspect ratio 9:16 with `isFixed = true`; output quality `.high`, resolution `._720`; trim 1–60 seconds.

### Deprecated

The old type names are now deprecated `typealias`es of the new types:

| Deprecated | Use |
|---|---|
| `ShopLiveShortFormEditorAspectRatio`, `ShopliveVideoEditorAspectRatio` | `ShopLiveShortformEditorAspectRatio` |
| `ShopLiveShortFormEditorTrimOption`, `ShopliveVideoEditorTrimOption` | `ShopLiveShortformEditorTrimOption` |
| `ShopLiveShortformEditorVideoOuputOption` | `ShopLiveShortformEditorVideoOutputOption` |
| `init(videoOutputQuality:videoOutputResoltuion:)` | `init(videoOutputQuality:videoOutputResolution:)` |

### Breaking changes

- Because the two old aspect ratio types (and the two old trim option types) are now the same type, code that declares separate overloads or extensions for each of them no longer compiles (invalid redeclaration). Keep a single declaration for the new type.
