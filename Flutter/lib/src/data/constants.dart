class Constants {
  static const String pluginVersion = '2.7.0';
  static const int groupCallMaxUserCount = 9;
  static const int roomIdMaxValue = 2147483647; // 2^31 - 1
  static const String spKeyEnableMuteMode = "enableMuteMode";
  static const String defaultAvatar =
      "https://dldir1.qq.com/hudongzhibo/TUIKit/resource/picture/user_default_icon.png";

  static const int blurLevelHigh = 3;
  static const int blurLevelClose = 0;
}

enum NetworkQualityHint {
  none,
  local,
  remote,
}

const setStateEvent = 'SET_STATE_EVENT';
const setStateEventOnCallReceived = 'SET_STATE_EVENT_ONCALLRECEIVED';
const setStateEventOnCallEnd = 'SET_STATE_EVENT_ONCALLEND';
const setStateEventRefreshTiming = 'SET_STATE_EVENT_REFRESH_TIMING';
const setStateEventOnCallBegin = 'SET_STATE_EVENT_CALLBEGIN';
const setStateEventGroupCallUserWidgetRefresh = 'SET_STATE_EVENT_GROUP_CALL_USER_WIDGET_REFRESH';
