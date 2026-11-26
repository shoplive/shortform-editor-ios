# Changelog

## 1.9.2

This release adds press-and-hold 2x playback to shortform detail and streamlines the editor upload flow.

### Changed
- Pressing and holding on the shortform detail screen now plays the video at 2x speed until you release, instead of having no effect.
- Editor upload now shows compression, upload and registration under one progress indicator with a single cancel confirmation, instead of separate indicators and cancel prompts for each step.
- The editor filter list is now centered to the screen width instead of being aligned to one side.

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
