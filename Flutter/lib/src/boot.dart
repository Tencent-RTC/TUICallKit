import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/extensions/call_service.dart';
import 'package:tencent_calls_uikit/src/extensions/call_ui_extension.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';

class Boot {
  static final Boot instance = Boot._internal();
  factory Boot() {
    return instance;
  }

  ITUINotificationCallback loginSuccessCallBack = (arg) {
    CallManager.instance.handleLoginSuccess(arg['sdkAppId'], arg['userId'], arg['userSig']);
  };

  ITUINotificationCallback logoutSuccessCallBack = (arg) {
    CallManager.instance.handleLogoutSuccess();
  };

  Boot._internal() {
    TUICallKitPlatform.instance;
    TUICore.instance.registerService(TUICALLKIT_SERVICE_NAME, CallService.instance);
    TUICore.instance.registerExtension(TUIExtensionID.joinInGroup, CallUIExtension.instance);

    TUICore.instance.registerEvent(loginSuccessEvent, loginSuccessCallBack);
    TUICore.instance.registerEvent(logoutSuccessEvent, logoutSuccessCallBack);

    CallState.instance.registerEngineObserver();
  }
}