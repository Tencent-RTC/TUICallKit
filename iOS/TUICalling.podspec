Pod::Spec.new do |spec|
  spec.name         = 'TUICalling'
  spec.version      = '10.3'
  spec.platform     = :ios
  spec.ios.deployment_target = '9.0'
  spec.license      = { :type => 'MIT', :file => 'LICENSE' }
  spec.homepage     = 'https://cloud.tencent.com/document/product/647'
  spec.documentation_url = 'https://cloud.tencent.com/document/product/647'
  spec.authors      = 'tencent video cloud'
  spec.summary      = 'TUICalling'
  spec.xcconfig     = { 'VALID_ARCHS' => 'armv7 arm64 x86_64' }

  spec.dependency 'Masonry'
  spec.dependency 'TUICore'

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
    trtc.source_files = 'Source/*.{h,m,mm}', 'Source/localized/**/*.{h,m,mm}', 'Source/Model/**/*.{h,m,mm}', 'Source/Service/**/*.{h,m,mm}', 'Source/UI/**/*.{h,m,mm}', 'Source/TUICallingKit_TRTC/*.{h,m,mm}'
    trtc.ios.framework = ['AVFoundation', 'Accelerate']
    trtc.library = 'c++', 'resolv'
    trtc.resource_bundles = {
      'TUICallingKitBundle' => ['Resources/Localized/**/*.strings', 'Resources/AudioFile', 'Resources/*.xcassets']
    }
  end
 
  spec.subspec 'Enterprise' do |enterprise|
    enterprise.dependency 'TXLiteAVSDK_Enterprise'
    enterprise.source_files = 'Source/*.{h,m,mm}', 'Source/localized/**/*.{h,m,mm}', 'Source/Model/**/*.{h,m,mm}', 'Source/Service/**/*.{h,m,mm}', 'Source/UI/**/*.{h,m,mm}', 'Source/TUICallingKit_Enterprise/*.{h,m,mm}'
    enterprise.ios.framework = ['AVFoundation', 'Accelerate', 'AssetsLibrary']
    enterprise.library = 'c++', 'resolv', 'sqlite3'
    enterprise.resource_bundles = {
      'TUICallingKitBundle' => ['Resources/Localized/**/*.strings', 'Resources/AudioFile', 'Resources/*.xcassets']
    }
  end
  
  spec.subspec 'Professional' do |professional|
    professional.dependency 'TXLiteAVSDK_Professional'
    professional.source_files = 'Source/*.{h,m,mm}', 'Source/localized/**/*.{h,m,mm}', 'Source/Model/**/*.{h,m,mm}', 'Source/Service/**/*.{h,m,mm}', 'Source/UI/**/*.{h,m,mm}', 'Source/TUICallingKit_Professional/*.{h,m,mm}'
    professional.ios.framework = ['AVFoundation', 'Accelerate', 'AssetsLibrary']
    professional.library = 'c++', 'resolv', 'sqlite3'
    professional.resource_bundles = {
      'TUICallingKitBundle' => ['Resources/Localized/**/*.strings', 'Resources/AudioFile', 'Resources/*.xcassets']
    }
  end
  
end
