Pod::Spec.new do |spec|
  spec.name         = 'TUICallKit'
  spec.version      = '10.5'
  spec.platform     = :ios
  spec.ios.deployment_target = '9.0'
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
  
  spec.dependency 'Masonry'
  spec.dependency 'TUICore'
  spec.dependency 'TUICallEngine'
  
  spec.requires_arc = true
  spec.static_framework = true
  spec.source = { :git => 'https://github.com/tencentyun/TUICalling.git' }
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.swift_version = '5.0'
  spec.default_subspec = 'TRTC'
  
  spec.subspec 'TRTC' do |trtc|
    trtc.dependency 'TXLiteAVSDK_TRTC'
    trtc.source_files = 'TUICallKit/*.{h,m,mm}', 'TUICallKit/localized/**/*.{h,m,mm}', 'TUICallKit/Service/**/*.{h,m,mm}', 'TUICallKit/UI/**/*.{h,m,mm}', 'TUICallKit/TUICallKit_TRTC/*.{h,m,mm}', 'TUICallKit/TUICallEngine_Framework/*.{h,m,mm}'
    trtc.ios.framework = ['AVFoundation', 'Accelerate']
    trtc.library = 'c++', 'resolv'
    trtc.resource_bundles = {
      'TUICallingKitBundle' => ['Resources/Localized/**/*.strings', 'Resources/AudioFile', 'Resources/*.xcassets']
    }
  end
  
  spec.subspec 'Professional' do |professional|
    professional.dependency 'TXLiteAVSDK_Professional'
    professional.source_files = 'TUICallKit/*.{h,m,mm}', 'TUICallKit/localized/**/*.{h,m,mm}', 'TUICallKit/Service/**/*.{h,m,mm}', 'TUICallKit/UI/**/*.{h,m,mm}', 'TUICallKit/TUICallKit_Professional/*.{h,m,mm}', 'TUICallKit/TUICallEngine_Framework/*.{h,m,mm}'
    professional.ios.framework = ['AVFoundation', 'Accelerate', 'AssetsLibrary']
    professional.library = 'c++', 'resolv', 'sqlite3'
    professional.resource_bundles = {
      'TUICallingKitBundle' => ['Resources/Localized/**/*.strings', 'Resources/AudioFile', 'Resources/*.xcassets']
    }
  end
  
end
