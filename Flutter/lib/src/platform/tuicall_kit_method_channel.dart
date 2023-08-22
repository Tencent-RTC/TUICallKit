import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_navigator_observer.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';

class MethodChannelTUICallKit extends TUICallKitPlatform {
  MethodChannelTUICallKit() {
    methodChannel.setMethodCallHandler((call) async {
      _handleNativeCall(call);
    });
  }

  @visibleForTesting
  final methodChannel = const MethodChannel('tuicall_kit');

  @override
  Future<void> startForegroundService() async {
    await methodChannel.invokeMethod('startForegroundService', {});
  }

  @override
  Future<void> stopForegroundService() async {
    await methodChannel.invokeMethod('stopForegroundService', {});
  }

  @override
  Future<void> startRing(String filePath) async {
    await methodChannel.invokeMethod('startRing', {"filePath": filePath});
  }

  @override
  Future<void> stopRing() async {
    await methodChannel.invokeMethod('stopRing', {});
  }

  @override
  Future<void> updateCallStateToNative() async {
    methodChannel.invokeMethod('updateCallStateToNative', {
      'selfUser': CallState.instance.selfUser.toJson(),
      'remoteUser': CallState.instance.remoteUserList.isNotEmpty
          ? CallState.instance.remoteUserList[0].toJson()
          : User().toJson(),
      'scene': CallState.instance.scene.index,
      'mediaType': CallState.instance.mediaType.index,
      'startTime': CallState.instance.startTime,
      'camera': CallState.instance.camera.index
    });
  }

  @override
  Future<void> startFloatWindow() async {
    await methodChannel.invokeMethod('startFloatWindow', {});
  }

  @override
  Future<void> stopFloatWindow() async {
    await methodChannel.invokeMethod('stopFloatWindow', {});
  }

  @override
  Future<bool> hasFloatPermission() async {
    return await methodChannel.invokeMethod('hasFloatPermission', {});
  }

  @override
  Future<bool> isAppInForeground() async {
    return await methodChannel.invokeMethod('isAppInForeground', {});
  }

  @override
  Future<bool> moveAppToFront(String event) async {
    return await methodChannel.invokeMethod('moveAppToFront', {"event": event});
  }

  @override
  Future<bool> initResources(Map resources) async {
    try {
      await methodChannel.invokeMethod('initResources', {"resources": resources});
    } on PlatformException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    }
    return true;
  }

  void _handleNativeCall(MethodCall call) {
    debugPrint(
        "CallHandler method:${call.method}, arguments:${call.arguments}");
    switch (call.method) {
      case "gotoCallingPage":
        _gotoCallingPage();
        break;
      case "handleCallReceived":
        _handleCallReceived();
        break;
      case "enableFloatWindow":
        _handleEnableFloatWindow(call);
        break;
      case "groupCall":
        _handleGroupCall(call);
        break;
      case "call":
        _handleCall(call);
        break;
      case "handleLoginSuccess":
        _handleLoginSuccess(call);
        break;
      case "handleLogoutSuccess":
        _handleLogoutSuccess();
        break;
      default:
        debugPrint("flutter: MethodNotImplemented ${call.method}");
        break;
    }
  }

  void _gotoCallingPage() {
    TUICallKitNavigatorObserver.getInstance().enterCallingPage();
  }

  void _handleCallReceived() {
    CallState.instance.handleCallReceived(
        CallState.instance.caller.id,
        CallState.instance.calleeIdList,
        CallState.instance.groupId,
        CallState.instance.mediaType);
  }

  void _handleEnableFloatWindow(MethodCall call) {
    var enable = call.arguments['enable'];
    TUICallKit.instance.enableFloatWindow(enable);
  }

  void _handleGroupCall(MethodCall call) {
    var groupId = call.arguments['groupId'];
    var userIdList = List<String>.from(call.arguments['userIdList']);
    TUICallMediaType mediaType =
        TUICallMediaType.values[call.arguments['mediaType']];
    TUICallKit.instance.groupCall(groupId, userIdList, mediaType);
  }

  void _handleCall(MethodCall call) {
    var userId = call.arguments['userId'];
    TUICallMediaType mediaType =
        TUICallMediaType.values[call.arguments['mediaType']];
    TUICallKit.instance.call(userId, mediaType);
  }

  void _handleLoginSuccess(MethodCall call) {
    var userId = call.arguments['userId'];
    var sdkAppId = call.arguments['sdkAppId'];
    var userSig = call.arguments['userSig'];
    CallManager.instance.handleLoginSuccess(sdkAppId, userId, userSig);
  }

  void _handleLogoutSuccess() {
    CallManager.instance.handleLogoutSuccess();
  }
}
