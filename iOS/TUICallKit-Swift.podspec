Pod::Spec.new do |spec|
  spec.name         = 'TUICallKit-Swift'
  spec.version      = '2.5.0.1025'
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
  
  spec.dependency 'TUICore'
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
    trtc.dependency 'TUICallEngine/TRTC', '~> 2.5.0.1020'
    trtc.source_files = 'TUICallKit-Swift/**/*.{h,m,mm,swift}'
    trtc.resource_bundles = {
      'TUICallKitBundle' => ['TUICallKit-Swift/Resources/**/*.strings', 'TUICallKit-Swift/Resources/AudioFile', 'TUICallKit-Swift/Resources/*.xcassets']
    }
    trtc.resource = ['TUICallKit-Swift/Resources/*.bundle']
  end
  
  spec.subspec 'Professional' do |professional|
    professional.dependency 'TXLiteAVSDK_Professional'
    professional.dependency 'TUICallEngine/Professional', '~> 2.5.0.1020'
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
