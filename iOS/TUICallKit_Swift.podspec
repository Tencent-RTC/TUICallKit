Pod::Spec.new do |spec|
  spec.name         = 'TUICallKit_Swift'
  spec.version      = '1.6.0.360'
  spec.platform     = :ios
  spec.ios.deployment_target = '10.0'
  spec.license      = { :type => 'Proprietary',
    :text => <<-LICENSE
    copyright 2017 tencent Ltd. All rights reserved.
    LICENSE
  }
  spec.homepage     = 'https://cloud.tencent.com/product/trtc'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/647/78730'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TUICallKit'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64' }
  spec.swift_version = '5.0'
  spec.static_framework = true
    spec.source = { :path => './' }
  spec.dependency 'SnapKit'
  spec.dependency 'TUICore', '~> 7.2.4123'
  
  spec.default_subspec = 'TRTC'
  spec.pod_target_xcconfig = { 'OTHER_LDFLAGS' => '-lObjC' }
  
  spec.subspec 'TRTC' do |trtc|
    trtc.dependency 'TXLiteAVSDK_TRTC'
    trtc.dependency 'TUICallEngine/TRTC', '~> 1.6.0.360'
    trtc.resource_bundles = {
      'TUICallingKitBundle' => ['Resources/*.gif', 'Resources/Localized/**/*.strings', 'Resources/AudioFile', 'Resources/*.xcassets']
    }
    trtc.source_files = 'TUICallKit-Swift/**/*.{h,m,mm,swift}'
    trtc.pod_target_xcconfig = { 'OTHER_SWIFT_FLAGS' => '$(inherited) -D USE_TRTC', 'GCC_PREPROCESSOR_DEFINITIONS' => "$(inherited) COCOAPODS=1 USE_TRTC=1" }
  end
  
  spec.subspec 'Professional' do |professional|
    professional.dependency 'TXLiteAVSDK_Professional'
    professional.dependency 'TUICallEngine/Professional', '~> 1.6.0.360'
    professional.resource_bundles = {
      'TUICallingKitBundle' => ['Resources/*.gif', 'Resources/Localized/**/*.strings', 'Resources/AudioFile', 'Resources/*.xcassets']
    }
    professional.source_files = 'TUICallKit-Swift/**/*.{h,m,mm,swift}'
  end
  
end
