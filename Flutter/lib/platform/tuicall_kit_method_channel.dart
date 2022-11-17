// Copyright (c) 2021 Tencent. All rights reserved.
// Author: tatemin
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tencent_calls_engine/tuicall_define.dart';

import 'tuicall_kit_platform_interface.dart';

/// An implementation of [TUICallKitPlatform] that uses method channels.
class MethodChannelTUICallKit extends TUICallKitPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('tuicall_kit');

  @override
  Future<TUIResult> login(int sdkAppId, String userId, String userSig) async {
    try {
      await methodChannel.invokeMethod('login',
          {'sdkAppId': sdkAppId, 'userId': userId, 'userSig': userSig});
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "login success");
  }

  @override
  Future<void> logout() async {
    await methodChannel.invokeMethod('logout');
  }

  @override
  Future<TUIResult> setSelfInfo(String nickname, String avatar) async {
    try {
      await methodChannel.invokeMethod(
          'setSelfInfo', {'nickname': nickname, 'avatar': avatar});
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "login success");
  }

  @override
  Future<void> call(String userId, TUICallMediaType callMediaType) async {
    await methodChannel.invokeMethod(
        'call', {'userId': userId, 'callMediaType': callMediaType.index});
  }

  @override
  Future<void> groupCall(String groupId, List<String> userIdList,
      TUICallMediaType callMediaType) async {
    await methodChannel.invokeMethod('groupCall', {
      'groupId': groupId,
      'userIdList': jsonEncode(userIdList),
      'callMediaType': callMediaType.index
    });
  }

  @override
  Future<void> joinInGroupCall(
      TUIRoomId roomId, String groupId, TUICallMediaType callMediaType) async {
    await methodChannel.invokeMethod('joinInGroupCall', {
      'roomId': roomId.toJson(),
      'groupId': groupId,
      'callMediaType': callMediaType.index
    });
  }

  @override
  Future<void> setCallingBell(String filePath) async {
    await methodChannel.invokeMethod('setCallingBell', {'filePath': filePath});
  }

  @override
  Future<void> enableMuteMode(bool enable) async {
    await methodChannel.invokeMethod('enableMuteMode', {'enable': enable});
  }

  @override
  Future<void> enableFloatWindow(bool enable) async {
    await methodChannel.invokeMethod('enableFloatWindow', {'enable': enable});
  }
}
