Pod::Spec.new do |spec|
  spec.name         = 'TUICallKit-Swift'
  spec.version      = '2.9.0.1230'
  spec.platform     = :ios
  spec.ios.deployment_target = '12.0'
  spec.license      = { :type => 'Proprietary',
    :text => <<-LICENSE
    copyright 2017 tencent Ltd. All rights reserved.
    LICENSE
  }
  spec.homepage     = 'https://cloud.tencent.com/document/product/647'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/647'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TUICallKit'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64' }
  
  spec.dependency 'TUICore', '~> 8.4.6667'
  spec.dependency 'SnapKit'

  spec.requires_arc = true
  spec.static_framework = true
  spec.source = { :path => './' }
  spec.swift_version = '5.0'
  
  spec.ios.framework = ['AVFoundation', 'Accelerate', 'AssetsLibrary']
  spec.library = 'c++', 'resolv', 'sqlite3'
  
  spec.default_subspec = 'TRTC'
  
  spec.subspec 'TRTC' do |trtc|
    trtc.dependency 'TXLiteAVSDK_TRTC'
    trtc.dependency 'RTCRoomEngine/TRTC', '~> 2.9.1'
    trtc.source_files = 'TUICallKit-Swift/**/*.{h,m,mm,swift}'
    trtc.resource_bundles = {
      'TUICallKitBundle' => ['TUICallKit-Swift/Resources/**/*.strings', 'TUICallKit-Swift/Resources/AudioFile', 'TUICallKit-Swift/Resources/*.xcassets']
    }
    trtc.resource = ['TUICallKit-Swift/Resources/*.bundle']
  end
  
  spec.subspec 'Professional' do |professional|
    professional.dependency 'TXLiteAVSDK_Professional'
    professional.dependency 'RTCRoomEngine/Professional', '~> 2.9.1'
    professional.source_files = 'TUICallKit-Swift/**/*.{h,m,mm,swift}'
    professional.resource_bundles = {
      'TUICallKitBundle' => ['TUICallKit-Swift/Resources/**/*.strings', 'TUICallKit-Swift/Resources/AudioFile', 'TUICallKit-Swift/Resources/*.xcassets']
    }
    professional.resource = ['TUICallKit-Swift/Resources/*.bundle']
  end
  
  spec.resource_bundles = {
    'TUICallKit-Swift_Privacy' => ['TUICallKit-Swift/Sources/PrivacyInfo.xcprivacy']
  }
  
end
