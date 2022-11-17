// Copyright (c) 2021 Tencent. All rights reserved.
// Author: tatemin

import 'package:flutter_test/flutter_test.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'package:tencent_calls_uikit/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/platform/tuicall_kit_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockCallsUikitPlatform
    with MockPlatformInterfaceMixin
    implements TUICallKitPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> call(String userId, callMediaType) {
    // TODO: implement call
    throw UnimplementedError();
  }

  @override
  Future<void> enableFloatWindow(bool enable) {
    // TODO: implement enableFloatWindow
    throw UnimplementedError();
  }

  @override
  Future<void> enableMuteMode(bool enable) {
    // TODO: implement enableMuteMode
    throw UnimplementedError();
  }

  @override
  Future<void> groupCall(
      String groupId, List<String> userIdList, callMediaType) {
    // TODO: implement groupCall
    throw UnimplementedError();
  }

  @override
  Future<void> joinInGroupCall(roomId, String groupId, callMediaType) {
    // TODO: implement joinInGroupCall
    throw UnimplementedError();
  }

  @override
  Future<void> setCallingBell(String filePath) {
    // TODO: implement setCallingBell
    throw UnimplementedError();
  }

  @override
  Future<void> setSelfInfo(String nickname, String avatar) {
    // TODO: implement setSelfInfo
    throw UnimplementedError();
  }
}

void main() {
  final TUICallKitPlatform initialPlatform = TUICallKitPlatform.instance;

  test('$MethodChannelTUICallKit is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelTUICallKit>());
  });

  test('getPlatformVersion', () async {
    TUICallKit callsUIKitPlugin = TUICallKit();
    MockCallsUikitPlatform fakePlatform = MockCallsUikitPlatform();
    TUICallKitPlatform.instance = fakePlatform;

    expect(await callsUIKitPlugin.getPlatformVersion(), '42');
  });
}
