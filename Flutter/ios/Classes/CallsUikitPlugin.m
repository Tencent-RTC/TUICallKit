#import "CallsUikitPlugin.h"
#if __has_include(<tuicall_kit/tencent_calls_uikit-Swift.h>)
#import <tuicall_kit/tencent_calls_uikit-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "tencent_calls_uikit-Swift.h"
#endif

@implementation CallsUikitPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
    [TUICallKitPlugin registerWithRegistrar:registrar];
}
@end
