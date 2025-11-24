Pod::Spec.new do |spec|
  spec.name             = 'ShopLiveShortformEditorSDK'
  spec.version          = '1.8.0.2'
  spec.summary          = "ShopLive Shortform Editor Framework for iOS"

  spec.homepage         = 'http://shoplive.cloud'
  spec.license = { :type => 'Copyright', :text => <<-LICENSE
                 Copyright 2021
                 Permission is granted to...
                 LICENSE
              }
  spec.author           = { 'hassan0424' => 'hassan@shoplive.cloud' }
  spec.source           = { :git => 'https://github.com/shoplive/shortform-editor-ios.git', :tag => spec.version.to_s }

  spec.platform     = :ios
  spec.ios.deployment_target = '13.0'
  spec.swift_version = "5"
  spec.vendored_frameworks = ['Frameworks/ShopLiveShortformEditorSDK.xcframework', 'Frameworks/ShopliveFilterSDK.xcframework']

end
