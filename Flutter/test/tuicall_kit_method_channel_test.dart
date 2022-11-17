// Copyright (c) 2021 Tencent. All rights reserved.
// Author: tatemin

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tencent_calls_uikit/platform/tuicall_kit_method_channel.dart';

void main() {
  MethodChannelTUICallKit platform = MethodChannelTUICallKit();
  const MethodChannel channel = MethodChannel('tuicall_kit');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
