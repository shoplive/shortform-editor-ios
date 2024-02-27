Pod::Spec.new do |s|
  s.name             = 'ShopLiveShortformEditorSDK'
  s.version          = '1.0.0'
  s.summary          = "ShopLive Shortform Editor Framework for iOS"

  s.homepage         = 'http://shoplive.cloud'
  s.license = { :type => 'Copyright', :text => <<-LICENSE
                 Copyright 2021
                 Permission is granted to...
                 LICENSE
              }
  s.author           = { 'hassan0424' => 'hassan@shoplive.cloud' }
  s.source           = { :git => 'https://github.com/shoplive/shortform-editor-ios', :tag => s.version.to_s }

  s.platform     = :ios
  s.ios.deployment_target = '12.1'
  s.swift_version = "5"
  s.vendored_frameworks = 'Frameworks/ShopLiveShortformEditorSDK.xcframework'

end
