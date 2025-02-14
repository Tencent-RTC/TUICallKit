import 'package:tencent_calls_uikit/src/platform/call_kit_platform_interface.dart';

enum TRTCLoggerLevel { info, warning, error }

class TRTCLogger {
  static void info(String message) async {
    await TUICallKitPlatform.instance.apiLog(TRTCLoggerLevel.info, message);
  }

  static void warning(String message) async {
    await TUICallKitPlatform.instance.apiLog(TRTCLoggerLevel.warning, message);
  }

  static void error(String message) async {
    await TUICallKitPlatform.instance.apiLog(TRTCLoggerLevel.error, message);
  }
}
