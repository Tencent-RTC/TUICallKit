// Copyright (c) 2021 Tencent. All rights reserved.
// Author: tatemin

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tencent_calls_uikit/src/extensions/trtc_logger.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/utils/permission.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';

class MockCallsUikitPlatform
    with MockPlatformInterfaceMixin
    implements TUICallKitPlatform {
  @override
  Future<void> apiLog(TRTCLoggerLevel level, String logString) {
    // TODO: implement apiLog
    throw UnimplementedError();
  }

  @override
  Future<void> closeMicrophone() {
    // TODO: implement closeMicrophone
    throw UnimplementedError();
  }

  @override
  Future<bool> hasFloatPermission() {
    // TODO: implement hasFloatPermission
    throw UnimplementedError();
  }

  @override
  Future<bool> hasPermissions({required List<PermissionType> permissions}) {
    // TODO: implement hasPermissions
    throw UnimplementedError();
  }

  @override
  Future<bool> initResources(Map resources) {
    // TODO: implement initResources
    throw UnimplementedError();
  }

  @override
  Future<bool> isAppInForeground() {
    // TODO: implement isAppInForeground
    throw UnimplementedError();
  }

  @override
  Future<void> openMicrophone() {
    // TODO: implement openMicrophone
    throw UnimplementedError();
  }

  @override
  Future<void> pullBackgroundApp() {
    // TODO: implement pullBackgroundApp
    throw UnimplementedError();
  }

  @override
  Future<PermissionResult> requestPermissions({required List<PermissionType> permissions, String title = "", String description = "", String settingsTip = ""}) {
    // TODO: implement requestPermissions
    throw UnimplementedError();
  }

  @override
  Future<bool> showIncomingBanner() {
    // TODO: implement showIncomingBanner
    throw UnimplementedError();
  }

  @override
  Future<void> startFloatWindow() {
    // TODO: implement startFloatWindow
    throw UnimplementedError();
  }

  @override
  Future<void> startForegroundService() {
    // TODO: implement startForegroundService
    throw UnimplementedError();
  }

  @override
  Future<void> startRing(String filePath) {
    // TODO: implement startRing
    throw UnimplementedError();
  }

  @override
  Future<void> stopFloatWindow() {
    // TODO: implement stopFloatWindow
    throw UnimplementedError();
  }

  @override
  Future<void> stopForegroundService() {
    // TODO: implement stopForegroundService
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
  Future<void> enableWakeLock(bool enable) {
    // TODO: implement enableWakeLock
    throw UnimplementedError();
  }

  @override
  Future<bool> isScreenLocked() {
    // TODO: implement isScreenLocked
    throw UnimplementedError();
  }

  @override
  Future<bool> checkUsbCameraService() {
    // TODO: implement checkUsbCameraService
    throw UnimplementedError();
  }

  @override
  Future<void> closeUsbCamera() {
    // TODO: implement closeUsbCamera
    throw UnimplementedError();
  }

  @override
  Future<void> imSDKInitSuccessEvent() {
    // TODO: implement imSDKInitSuccessEvent
    throw UnimplementedError();
  }

  @override
  Future<void> loginSuccessEvent() {
    // TODO: implement loginSuccessEvent
    throw UnimplementedError();
  }

  @override
  Future<void> logoutSuccessEvent() {
    // TODO: implement logoutSuccessEvent
    throw UnimplementedError();
  }

  @override
  Future<void> openUsbCamera(int viewId) {
    // TODO: implement openUsbCamera
    throw UnimplementedError();
  }

  @override
  Future<void> openLockScreenApp() {
    // TODO: implement openLockScreenApp
    throw UnimplementedError();
  }

  @override
  Future<bool> isSamsungDevice() {
    // TODO: implement isSamsungDevice
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
