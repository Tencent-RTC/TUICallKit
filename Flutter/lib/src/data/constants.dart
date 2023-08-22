import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';

class Constants {
  static const int groupCallMaxUserCount = 9;
  static const int roomIdMaxValue = 2147483647; // 2^31 - 1
  static const String spKeyEnableMuteMode = "enableMuteMode";
  static const String defaultAvatar =
      "https://dldir1.qq.com/hudongzhibo/TUIKit/resource/picture/user_default_icon.png";
  static String defaultNickname = CallKit_t('匿名');
}
