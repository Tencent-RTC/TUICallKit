#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint tuicall_kit.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'tencent_calls_uikit'
  s.version          = '0.0.1'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'RTCRoomEngine/Professional', '~>3.5.0'
  s.dependency 'TUICore', '>= 8.7.7201'
  s.dependency 'SnapKit'
  s.platform = :ios, '9.0'
  s.static_framework = true
  
  s.resource_bundles = {'TUICallKitBundle' => ['Assets/*.xcassets']}

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'
 
end
