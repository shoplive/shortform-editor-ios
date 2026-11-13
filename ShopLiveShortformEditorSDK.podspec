Pod::Spec.new do |spec|
  spec.name             = 'ShopLiveShortformEditorSDK'
  spec.version          = '1.9.1'
  spec.summary          = "ShopLive Shortform Editor Framework for iOS"

  spec.homepage         = 'http://shoplive.cloud'
  spec.license = { :type => 'Copyright', :text => <<-LICENSE
                 Copyright 2021
                 Permission is granted to...
                 LICENSE
              }
  spec.author           = { 'Shoplive' => 'shoplive-eng@shoplive.cloud' }
  spec.source           = { :git => 'https://github.com/shoplive/shortform-editor-ios.git', :tag => spec.version.to_s }

  spec.platform     = :ios
  spec.ios.deployment_target = '15.0'
  spec.swift_version = "5"
  spec.vendored_frameworks = ['Frameworks/ShopLiveShortformEditorSDK.xcframework', 'Frameworks/ShopliveFilterSDK.xcframework']
  # 에디터는 Common 을 런타임에 링크한다 — 라이브 SDK 1.x · 숏폼과 같은 버전으로 맞춘다.
  spec.dependency 'ShopliveSDKCommon', '1.9.0'
  # ffmpegkit 은 CocoaPods trunk 의 ffmpeg-kit pod 이 내려가(2025) 의존으로 선언할 수 없다 — README 참고.
  #
  # Maintainer note: ffmpegkit is not declared as a pod dependency, so the import validation step of
  # `pod spec lint` / `pod repo push` cannot link the editor framework. Run them with
  # `--skip-import-validation` (e.g. `pod spec lint ShopLiveShortformEditorSDK.podspec --skip-import-validation`).

end
