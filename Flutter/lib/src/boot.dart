import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/extensions/call_service.dart';
import 'package:tencent_calls_uikit/src/extensions/call_ui_extension.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class Boot {
  static final Boot instance = Boot._internal();

  factory Boot() {
    return instance;
  }

  ITUINotificationCallback loginSuccessCallBack = (arg) {
    TUICallKitPlatform.instance.loginSuccessEvent();
    CallManager.instance.handleLoginSuccess(arg['sdkAppId'], arg['userId'], arg['userSig']);
  };

  ITUINotificationCallback logoutSuccessCallBack = (arg) {
    TUICallKitPlatform.instance.logoutSuccessEvent();
    CallManager.instance.handleLogoutSuccess();
  };

  ITUINotificationCallback imSDKInitSuccessCallBack = (arg) {
    TUICallKitPlatform.instance.imSDKInitSuccessEvent();
    CallState.instance.registerEngineObserver();
  };

  Boot._internal() {
    TUICallKitPlatform.instance;
    TUICore.instance.registerService(TUICALLKIT_SERVICE_NAME, CallService.instance);
    TUICore.instance.registerExtension(TUIExtensionID.joinInGroup, CallUIExtension.instance);

    TUICore.instance.registerEvent(loginSuccessEvent, loginSuccessCallBack);
    TUICore.instance.registerEvent(logoutSuccessEvent, logoutSuccessCallBack);

    TUICore.instance.registerEvent(imSDKInitSuccessEvent, imSDKInitSuccessCallBack);
  }
}
