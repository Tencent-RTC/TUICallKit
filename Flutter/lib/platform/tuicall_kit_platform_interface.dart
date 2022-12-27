// Copyright (c) 2021 Tencent. All rights reserved.
// Author: tatemin

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'tuicall_kit_method_channel.dart';
import 'package:tencent_calls_engine/tuicall_define.dart';

abstract class TUICallKitPlatform extends PlatformInterface {
  TUICallKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static TUICallKitPlatform _instance = MethodChannelTUICallKit();

  static TUICallKitPlatform get instance => _instance;

  static set instance(TUICallKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<TUIResult> login(int sdkAppId, String userId, String userSig) async {
    return await instance.login(sdkAppId, userId, userSig);
  }

  Future<void> logout() async {
    await instance.logout();
  }

  Future<TUIResult> setSelfInfo(String nickname, String avatar) async {
    return await instance.setSelfInfo(nickname, avatar);
  }

  Future<void> call(String userId, TUICallMediaType callMediaType, [TUICallParams? params]) async {
    await instance.call(userId, callMediaType, params);
  }

  Future<void> groupCall(String groupId, List<String> userIdList,
      TUICallMediaType callMediaType, [TUICallParams? params]) async {
    await instance.groupCall(groupId, userIdList, callMediaType, params);
  }

  Future<void> joinInGroupCall(
      TUIRoomId roomId, String groupId, TUICallMediaType callMediaType) async {
    await instance.joinInGroupCall(roomId, groupId, callMediaType);
  }

  Future<void> setCallingBell(String filePath) async {
    await instance.setCallingBell(filePath);
  }

  Future<void> enableMuteMode(bool enable) async {
    await instance.enableMuteMode(enable);
  }

  Future<void> enableFloatWindow(bool enable) async {
    await instance.enableFloatWindow(enable);
  }
}
