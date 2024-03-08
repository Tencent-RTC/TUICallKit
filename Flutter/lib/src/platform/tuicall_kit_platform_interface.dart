import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tencent_calls_uikit/src/extensions/trtc_logger.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_method_channel.dart';

abstract class TUICallKitPlatform extends PlatformInterface {
  TUICallKitPlatform() : super(token: _token);

  static final Object _token = Object();

  static TUICallKitPlatform _instance = MethodChannelTUICallKit();

  static TUICallKitPlatform get instance => _instance;

  static set instance(TUICallKitPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> startForegroundService() async {
    await instance.startForegroundService();
  }

  Future<void> stopForegroundService() async {
    await instance.stopForegroundService();
  }

  Future<void> startRing(String filePath) async {
    await instance.startRing(filePath);
  }

  Future<void> stopRing() async {
    await instance.stopRing();
  }

  Future<void> updateCallStateToNative() async {
    await instance.updateCallStateToNative();
  }

  Future<void> startFloatWindow() async {
    await instance.startFloatWindow();
  }

  Future<void> stopFloatWindow() async {
    await instance.stopFloatWindow();
  }

  Future<bool> hasFloatPermission() async {
    return await instance.hasFloatPermission();
  }

  Future<bool> isAppInForeground() async {
    return await instance.isAppInForeground();
  }

  Future<bool> moveAppToFront(String event) async {
    return await instance.moveAppToFront(event);
  }

  Future<bool> initResources(Map resources) async {
    return await instance.initResources(resources);
  }

  Future<void> openMicrophone() async {
    await instance.openMicrophone();
  }

  Future<void> closeMicrophone() async {
    await instance.openMicrophone();
  }

  Future<void> apiLog(TRTCLoggerLevel level, String logString) async {
    await instance.apiLog(level, logString);
  }
}
