
[![Swift Version][swift-image]][swift-url]
[![Build Status][travis-image]][travis-url]
[![Platform](https://img.shields.io/cocoapods/p/LFAlertController.svg?style=flat)](http://cocoapods.org/pods/LFAlertController)

# ShopLive SDK iOS
<br />
<p align="center">
  <a href="https://www.shoplive.cloud/en">
    <img src="https://avatars.githubusercontent.com/u/74698543?s=200&v=4" alt="Logo" width="80" height="80">
  </a>
</p>

## Features

- [x] PIP

## Requirements

- iOS 13.0+

## Build

### Archive

#### Simulator
```
xcodebuild archive -scheme ShopLiveSDK -archivePath ./ShopLiveSDK-simulator.xcarchive -sdk iphonesimulator SKIP_INSTALL=NO
```

#### iPhone
```
xcodebuild archive -scheme ShopLiveSDK -archivePath ./ShopLiveSDK-iphoneos.xcarchive -sdk iphoneos SKIP_INSTALL=NO
```

### Create XCFramework

```
xcodebuild -create-xcframework \
 -framework ./ShopLiveSDK-simulator.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework \
 -framework ./ShopLiveSDK-iphoneos.xcarchive/Products/Library/Frameworks/ShopLiveSDK.framework \
 -output ../ShopLiveSDK-library/ShopLiveSDK.xcframework
```

## Contribute

We would love you for the contribution to **ShopLiveSDK**, check the ``LICENSE`` file for more info.

## Meta

Your Name – [@YourTwitter](https://twitter.com/dbader_org) – YourEmail@example.com

Distributed under the XYZ license. See ``LICENSE`` for more information.

[https://github.com/yourname/github-link](https://github.com/dbader/)

[swift-image]:https://img.shields.io/badge/swift-3.0-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[travis-image]: https://img.shields.io/travis/dbader/node-datadog-metrics/master.svg?style=flat-square
[travis-url]: https://travis-ci.org/dbader/node-datadog-metrics
[codebeat-image]: https://codebeat.co/badges/c19b47ea-2f9d-45df-8458-b2d952fe9dad
[codebeat-url]: https://codebeat.co/projects/github-com-vsouza-awesomeios-com
