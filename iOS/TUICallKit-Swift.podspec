Pod::Spec.new do |spec|
  spec.name         = 'TUICallKit-Swift'
  spec.version      = '2.3.0.910'
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
    trtc.dependency 'TUICallEngine/TRTC', '~> 2.3.0.910'
    trtc.source_files = 'TUICallKit-Swift/**/*.{h,m,mm,swift}'
    trtc.resource_bundles = {
      'TUICallKitBundle' => ['TUICallKit-Swift/Resources/*.gif', 'TUICallKit-Swift/Resources/**/*.strings', 'TUICallKit-Swift/Resources/AudioFile', 'TUICallKit-Swift/Resources/*.xcassets']
    }
    trtc.resource = ['TUICallKit-Swift/Resources/*.bundle']
    trtc.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -D USE_TRTC', 'GCC_PREPROCESSOR_DEFINITIONS' => "$(inherited) COCOAPODS=1 USE_TRTC=1" }
  end
  
  spec.subspec 'Professional' do |professional|
    professional.dependency 'TXLiteAVSDK_Professional'
    professional.dependency 'TUICallEngine/Professional', '~> 2.3.0.910'
    professional.source_files = 'TUICallKit-Swift/**/*.{h,m,mm,swift}'
    professional.resource_bundles = {
      'TUICallKitBundle' => ['TUICallKit-Swift/Resources/*.gif', 'TUICallKit-Swift/Resources/**/*.strings', 'TUICallKit-Swift/Resources/AudioFile', 'TUICallKit-Swift/Resources/*.xcassets']
    }
    professional.resource = ['TUICallKit-Swift/Resources/*.bundle']
  end

end
