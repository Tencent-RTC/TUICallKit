Pod::Spec.new do |spec|
  spec.name         = 'TUICallKit'
  spec.version      = '2.4.0.970'
  spec.platform     = :ios
  spec.ios.deployment_target = '10.0'
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
  
  spec.requires_arc = true
  spec.static_framework = true
  spec.source = { :path => './' }
  spec.swift_version = '5.0'

  spec.ios.framework = ['AVFoundation', 'Accelerate', 'AssetsLibrary']
  spec.library = 'c++', 'resolv', 'sqlite3'

  spec.default_subspec = 'TRTC'
  
  spec.subspec 'TRTC' do |trtc|
    trtc.dependency 'TXLiteAVSDK_TRTC'
    trtc.dependency 'TUICallEngine/TRTC', '~> 2.4.0.970'
    trtc.source_files = 'TUICallKit/*.{h,m,mm}', 'TUICallKit/localized/**/*.{h,m,mm}', 'TUICallKit/Service/**/*.{h,m,mm}', 'TUICallKit/Config/*.{h,m,mm}', 'TUICallKit/Base/*.{h,m,mm}', 'TUICallKit/Utils/**/*.{h,m,mm}', 'TUICallKit/UI/**/*.{h,m,mm}', 'TUICallKit/TUICallKit_TRTC/*.{h,m,mm}'
    trtc.resource_bundles = {
      'TUICallingKitBundle' => ['TUICallKit/Resources/*.gif', 'TUICallKit/Resources/Localized/**/*.strings', 'TUICallKit/Resources/AudioFile', 'TUICallKit/Resources/*.xcassets']
    }
    trtc.resource = ['TUICallKit/Resources/*.bundle']
  end
  
  spec.subspec 'Professional' do |professional|
    professional.dependency 'TXLiteAVSDK_Professional'
    professional.dependency 'TUICallEngine/Professional', '~> 2.4.0.970'
    professional.source_files = 'TUICallKit/*.{h,m,mm}', 'TUICallKit/localized/**/*.{h,m,mm}', 'TUICallKit/Service/**/*.{h,m,mm}', 'TUICallKit/Config/*.{h,m,mm}', 'TUICallKit/Base/*.{h,m,mm}', 'TUICallKit/Utils/**/*.{h,m,mm}', 'TUICallKit/UI/**/*.{h,m,mm}', 'TUICallKit/TUICallKit_Professional/*.{h,m,mm}'
    professional.resource_bundles = {
      'TUICallingKitBundle' => ['TUICallKit/Resources/*.gif', 'TUICallKit/Resources/Localized/**/*.strings', 'TUICallKit/Resources/AudioFile', 'TUICallKit/Resources/*.xcassets']
    }
    professional.resource = ['TUICallKit/Resources/*.bundle']
  end
  
  spec.resource_bundles = {
    'TUICallKit_Privacy' => ['TUICallKit/Sources/PrivacyInfo.xcprivacy']
  }
  
end
