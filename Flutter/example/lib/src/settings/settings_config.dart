import 'package:tencent_calls_engine/tencent_calls_engine.dart';

class SettingsConfig {
  static const defaultAvatar =
      "https://imgcache.qq.com/qcloud/public/static//avatar3_100.20191230.png";
  static const version = '1.0.0';

  static String userId = '';
  static String avatar = '';
  static String nickname = '';

  static bool muteMode = false;
  static bool enableFloatWindow = false;

  static int intRoomId = 0;
  static String strRoomId = "";
  static int timeout = 30;
  static String extendInfo = "";
  static TUIOfflinePushInfo? offlinePushInfo;

  static Resolution resolution = Resolution.resolution_640_480;
  static ResolutionMode resolutionMode = ResolutionMode.portrait;
  static FillMode fillMode = FillMode.fill;
  static Rotation rotation = Rotation.rotation_0;
  static double beautyLevel = 6;
}
