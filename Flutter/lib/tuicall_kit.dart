import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_engine/tuicall_define.dart';

class TUICallKit extends PlatformInterface {
  TUICallKit() : super(token: _token);

  static final Object _token = Object();

  static TUICallKit _instance = TUICallKit();

  static TUICallKit get instance => _instance;

  static set instance(TUICallKit instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// login TUICallKit
  ///
  /// @param sdkAppId      sdkAppId
  /// @param userId        userId
  /// @param userSig       userSig
  Future<TUIResult> login(
      {required int sdkAppId,
      required String userId,
      required String userSig}) async {
    return await TUICallKitPlatform.instance.login(sdkAppId, userId, userSig);
  }

  /// logout TUICallKit
  ///
  Future<void> logout() async {
    return await TUICallKitPlatform.instance.logout();
  }

  /// Set user profile
  ///
  /// @param nickname User name, which can contain up to 500 bytes
  /// @param avatar   User profile photo URL, which can contain up to 500 bytes
  ///                 For example: https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png
  /// @param callback Set the result callback
  Future<TUIResult> setSelfInfo(String nickname, String avatar) async {
    return await TUICallKitPlatform.instance.setSelfInfo(nickname, avatar);
  }

  /// Make a call
  ///
  /// @param userId        callees
  /// @param callMediaType Call type
  Future<void> call(String userId, TUICallMediaType callMediaType, [TUICallParams? params]) async {
    return await TUICallKitPlatform.instance.call(userId, callMediaType, params);
  }

  ///Make a group call
  ///
  ///@param groupId       GroupId
  ///@param userIdList    List of userId
  ///@param callMediaType Call type
  Future<void> groupCall(String groupId, List<String> userIdList,
      TUICallMediaType callMediaType, [TUICallParams? params]) async {
    return await TUICallKitPlatform.instance
        .groupCall(groupId, userIdList, callMediaType, params);
  }

  ///Join a current call
  ///
  ///@param roomId        current call room ID
  ///@param callMediaType call type
  Future<void> joinInGroupCall(
      TUIRoomId roomId, String groupId, TUICallMediaType callMediaType) async {
    return await TUICallKitPlatform.instance
        .joinInGroupCall(roomId, groupId, callMediaType);
  }

  ///Set the ringtone (preferably shorter than 30s)
  ///
  ///@param filePath Callee ringtone path
  Future<void> setCallingBell(String filePath) async {
    return await TUICallKitPlatform.instance.setCallingBell(filePath);
  }

  ///Enable the mute mode (the callee doesn't ring)
  Future<void> enableMuteMode(bool enable) async {
    return await TUICallKitPlatform.instance.enableMuteMode(enable);
  }

  ///Enable the floating window
  Future<void> enableFloatWindow(bool enable) async {
    return await TUICallKitPlatform.instance.enableFloatWindow(enable);
  }
}
