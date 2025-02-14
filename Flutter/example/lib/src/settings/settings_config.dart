import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';

class SettingsConfig {
  static const defaultAvatar =
      "https://imgcache.qq.com/qcloud/public/static//avatar3_100.20191230.png";
  static const version = '1.0.0';

  static String userId = '';
  static String avatar = '';
  static String nickname = '';

  static bool muteMode = false;
  static bool enableFloatWindow = false;
  static bool showBlurBackground = false;
  static bool showIncomingBanner = false;

  static int intRoomId = 0;
  static String strRoomId = "";
  static int timeout = 30;
  static String extendInfo = "";
  static TUIOfflinePushInfo? offlinePushInfo;

  static Resolution resolution = Resolution.resolution_1280_720;
  static ResolutionMode resolutionMode = ResolutionMode.portrait;
  static FillMode fillMode = FillMode.fill;
  static Rotation rotation = Rotation.rotation_0;
  static double beautyLevel = 6;
}
