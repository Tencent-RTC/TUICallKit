import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_navigator_observer.dart';

class TUICallKit {
  static final TUICallKit _instance = TUICallKit();

  static TUICallKit get instance => _instance;

  static TUICallKitNavigatorObserver navigatorObserver =
      TUICallKitNavigatorObserver.getInstance();

  /// login TUICallKit
  ///
  /// @param sdkAppId      sdkAppId
  /// @param userId        userId
  /// @param userSig       userSig
  Future<TUIResult> login(int sdkAppId, String userId, String userSig) async {
    return await CallManager.instance.login(sdkAppId, userId, userSig);
  }

  /// logout TUICallKit
  ///
  Future<void> logout() async {
    return await CallManager.instance.logout();
  }

  /// Set user profile
  ///
  /// @param nickname User name, which can contain up to 500 bytes
  /// @param avatar   User profile photo URL, which can contain up to 500 bytes
  ///                 For example: https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png
  /// @param callback Set the result callback
  Future<TUIResult> setSelfInfo(String nickname, String avatar) async {
    return await CallManager.instance.setSelfInfo(nickname, avatar);
  }

  /// Make a call
  ///
  /// @param userId        callees
  /// @param callMediaType Call type
  Future<TUIResult> call(String userId, TUICallMediaType callMediaType,
      [TUICallParams? params]) async {
    return await CallManager.instance.call(userId, callMediaType, params);
  }

  ///Make a group call
  ///
  ///@param groupId       GroupId
  ///@param userIdList    List of userId
  ///@param callMediaType Call type
  Future<TUIResult> groupCall(
      String groupId, List<String> userIdList, TUICallMediaType callMediaType,
      [TUICallParams? params]) async {
   return await CallManager.instance.groupCall(groupId, userIdList, callMediaType, params);
  }

  ///Join a current call
  ///
  ///@param roomId        current call room ID
  ///@param callMediaType call type
  Future<void> joinInGroupCall(
      TUIRoomId roomId, String groupId, TUICallMediaType callMediaType) async {
    return await CallManager.instance
        .joinInGroupCall(roomId, groupId, callMediaType);
  }


  /// Set the ringtone (preferably shorter than 30s)
  ///
  /// First introduce the ringtone resource into the project
  /// Then set the resource as a ringtone
  ///
  /// @param filePath Callee ringtone path
  Future<void> setCallingBell(String assetName) async {
    return await CallManager.instance.setCallingBell(assetName);
  }


  ///Enable the mute mode (the callee doesn't ring)
  Future<void> enableMuteMode(bool enable) async {
    return await CallManager.instance.enableMuteMode(enable);
  }

  ///Enable the floating window
  Future<void> enableFloatWindow(bool enable) async {
    return await CallManager.instance.enableFloatWindow(enable);
  }
}
