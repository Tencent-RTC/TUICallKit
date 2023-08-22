import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class PermissionRequest {
  static String getPermissionRequestTitle(TUICallMediaType type) {
    if (TUICallMediaType.audio == type) {
      return CallKit_t("申请麦克风权限");
    } else {
      return CallKit_t("申请麦克风、摄像头权限");
    }
  }

  static String getPermissionRequestDescription(TUICallMediaType type) {
    if (TUICallMediaType.audio == type) {
      return CallKit_t("需要访问您的麦克风权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。");
    } else {
      return CallKit_t("需要访问您的麦克风和摄像头权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。");
    }
  }

  static String getPermissionRequestSettingsTip(TUICallMediaType type) {
    if (TUICallMediaType.audio == type) {
      return "${CallKit_t("申请麦克风权限")}\n${CallKit_t("需要访问您的麦克风权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。")}";
    } else {
      return "${CallKit_t("申请麦克风、摄像头权限")}\n${CallKit_t("需要访问您的麦克风和摄像头权限，开启后用于语音通话、多人语音通话、视频通话、多人视频通话等功能。")}";
    }
  }

  static Future<TUIPermissionResult> checkCallingPermission(
      TUICallMediaType type) async {
    TUIPermissionResult result = TUIPermissionResult.denied;
    if (TUICallMediaType.video == type) {
      result = await TUIPermission.request(
          permissions: [TUIPermissions.camera, TUIPermissions.microphone],
          title: getPermissionRequestTitle(type),
          description: getPermissionRequestDescription(type),
          settingsTip: getPermissionRequestDescription(type));
    } else {
      result = await TUIPermission.request(
          permissions: [TUIPermissions.microphone],
          title: getPermissionRequestTitle(type),
          description: getPermissionRequestDescription(type),
          settingsTip: getPermissionRequestDescription(type));
    }
    return result;
  }
}
