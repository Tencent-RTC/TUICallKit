Pod::Spec.new do |spec|
  spec.name         = 'TUICallKit'
  spec.version      = '1.5.1.310'
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
  spec.dependency 'TUICore', '~> 7.1.3925'
  
  spec.requires_arc = true
  spec.static_framework = true
  spec.source = { :path => './' }
  spec.pod_target_xcconfig = {
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
  }
  spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  spec.swift_version = '5.0'

  spec.ios.framework = ['AVFoundation', 'Accelerate', 'AssetsLibrary']
  spec.library = 'c++', 'resolv', 'sqlite3'

  spec.default_subspec = 'TRTC'
  
  spec.subspec 'TRTC' do |trtc|
    trtc.dependency 'TXLiteAVSDK_TRTC'
    trtc.dependency 'TUICallEngine/TRTC', '1.5.1.310'
    trtc.source_files = 'TUICallKit/*.{h,m,mm}', 'TUICallKit/localized/**/*.{h,m,mm}', 'TUICallKit/Service/**/*.{h,m,mm}', 'TUICallKit/Config/*.{h,m,mm}', 'TUICallKit/Base/*.{h,m,mm}', 'TUICallKit/UI/**/*.{h,m,mm}', 'TUICallKit/TUICallKit_TRTC/*.{h,m,mm}', 'TUICallKit/TUICallEngine_Framework/*.{h,m,mm}'
    trtc.resource_bundles = {
      'TUICallingKitBundle' => ['Resources/*.gif', 'Resources/Localized/**/*.strings', 'Resources/AudioFile', 'Resources/*.xcassets']
    }
  end
  
  spec.subspec 'Professional' do |professional|
    professional.dependency 'TXLiteAVSDK_Professional'
    professional.dependency 'TUICallEngine/Professional', '1.5.1.310'
    professional.source_files = 'TUICallKit/*.{h,m,mm}', 'TUICallKit/localized/**/*.{h,m,mm}', 'TUICallKit/Service/**/*.{h,m,mm}', 'TUICallKit/Config/*.{h,m,mm}', 'TUICallKit/Base/*.{h,m,mm}', 'TUICallKit/UI/**/*.{h,m,mm}', 'TUICallKit/TUICallKit_Professional/*.{h,m,mm}', 'TUICallKit/TUICallEngine_Framework/*.{h,m,mm}'
  professional.resource_bundles = {
    'TUICallingKitBundle' => ['Resources/*.gif', 'Resources/Localized/**/*.strings', 'Resources/AudioFile', 'Resources/*.xcassets']
  }
  end
  
end
