# Changelog

## 1.9.1

This release adds a runtime display language for both SDKs and raises the minimum iOS version.

### Requirements
- iOS 15.0 or later is now required.
- Shoplive Common SDK 1.9.0 or later is required.

### Added
- `ShopLiveShortform.setLocale(_:)` and `ShopLiveShortformEditor.setLocale(_:)` set the SDK display language (ko, en, ja, zh-CN, zh-TW); the choice persists across app launches, and `nil` returns to the device language.
- `ShopLiveShortform.getLocale()` and `ShopLiveShortformEditor.getLocale()` return the language currently in use.

### Changed
- The editor button titles `nextButtonTitle`, `confirmButtonTitle` and `cameraRollButtonTitle` now follow the SDK language by default, and setting an empty string removes your custom title instead of showing a blank one.
- Shortform detail playback now starts at a lower video quality to begin faster, then adapts as before.

### Fixed
- A shortform list that failed to load its next page no longer stays stuck; scrolling again retries the request.
