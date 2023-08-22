// Copyright (c) 2021 Tencent. All rights reserved.
// Author: tatemin

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';

class MockCallsUikitPlatform
    with MockPlatformInterfaceMixin
    implements TUICallKitPlatform {

  @override
  Future<void> startForegroundService() {
    // TODO: implement startForegroundService
    throw UnimplementedError();
  }


  @override
  Future<void> stopForegroundService() {
    // TODO: implement stopForegroundService
    throw UnimplementedError();
  }


  @override
  Future<void> startRing(String filePath) {
    // TODO: implement startRing
    throw UnimplementedError();
  }

  @override
  Future<void> stopRing() {
    // TODO: implement stopRing
    throw UnimplementedError();
  }

  @override
  Future<void> updateCallStateToNative() {
    // TODO: implement updateCallStateToNative
    throw UnimplementedError();
  }

  @override
  Future<void> startFloatWindow() {
    // TODO: implement startFloatWindow
    throw UnimplementedError();
  }

  @override
  Future<void> stopFloatWindow() {
    // TODO: implement stopFloatWindow
    throw UnimplementedError();
  }

  @override
  Future<bool> hasFloatPermission() {
    // TODO: implement hasFloatPermission
    throw UnimplementedError();
  }

  @override
  Future<bool> isAppInForeground() {
    // TODO: implement isAppInForeground
    throw UnimplementedError();
  }

  @override
  Future<bool> moveAppToFront(String event) {
    // TODO: implement moveAppToFront
    throw UnimplementedError();
  }

  @override
  Future<bool> initResources(Map<dynamic, dynamic> resources) {
    // TODO: implement initResources
    throw UnimplementedError();
  }
}

void main() {
  test('StringsUtils', () async {
    String? a = '';
    String? b;
    debugPrint(StringStream.makeNull(a, "a default"));
    debugPrint(StringStream.makeNull(b, "b default"));

    String c = '';
    debugPrint(StringStream.makeNonNull(c, "c default"));
  });
}
