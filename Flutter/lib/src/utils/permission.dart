import 'package:tencent_calls_uikit/src/call_define.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/platform/call_kit_platform_interface.dart';

enum PermissionResult {
  granted,
  denied,
  requesting,
}

enum PermissionType {
  camera,
  microphone,
  bluetooth,
}

class Permission {
  static String getPermissionRequestTitle(TUICallMediaType type) {
    if (TUICallMediaType.audio == type) {
      return CallKit_t("applyForMicrophonePermission");
    } else {
      return CallKit_t("applyForMicrophoneAndCameraPermissions");
    }
  }

  static String getPermissionRequestDescription(TUICallMediaType type) {
    if (TUICallMediaType.audio == type) {
      return CallKit_t("needToAccessMicrophonePermission");
    } else {
      return CallKit_t("needToAccessMicrophoneAndCameraPermissions");
    }
  }

  static String getPermissionRequestSettingsTip(TUICallMediaType type) {
    if (TUICallMediaType.audio == type) {
      return "${CallKit_t("applyForMicrophonePermission")}\n${CallKit_t("needToAccessMicrophonePermission")}";
    } else {
      return "${CallKit_t("applyForMicrophoneAndCameraPermissions")}\n${CallKit_t("needToAccessMicrophoneAndCameraPermissions")}";
    }
  }

  static Future<PermissionResult> request(TUICallMediaType type) async {
    PermissionResult result = PermissionResult.denied;
    if (TUICallMediaType.video == type) {
      result = await TUICallKitPlatform.instance.requestPermissions(
          permissions: [PermissionType.camera, PermissionType.microphone],
          title: getPermissionRequestTitle(type),
          description: getPermissionRequestDescription(type),
          settingsTip: getPermissionRequestDescription(type));
    } else {
      result = await TUICallKitPlatform.instance.requestPermissions(
          permissions: [PermissionType.microphone],
          title: getPermissionRequestTitle(type),
          description: getPermissionRequestDescription(type),
          settingsTip: getPermissionRequestDescription(type));
    }
    return result;
  }

  static Future<bool> has({required List<PermissionType> permissions}) async {
    return await TUICallKitPlatform.instance.hasPermissions(permissions: permissions);
  }
}
