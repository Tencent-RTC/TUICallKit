import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/extensions/trtc_logger.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'package:tencent_calls_uikit/src/utils/permission.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

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
    List remoteUserList = [];
    for (var i = 0; i < CallState.instance.remoteUserList.length; ++i) {
      remoteUserList.add(CallState.instance.remoteUserList[i].toJson());
    }

    methodChannel.invokeMethod('updateCallStateToNative', {
      'selfUser': CallState.instance.selfUser.toJson(),
      'remoteUserList': remoteUserList.isNotEmpty ? remoteUserList : [],
      'scene': CallState.instance.scene.index,
      'mediaType': CallState.instance.mediaType.index,
      'startTime': CallState.instance.startTime,
      'camera': CallState.instance.camera.index,
      'isCameraOpen': CallState.instance.isCameraOpen,
      'isMicrophoneMute': CallState.instance.isMicrophoneMute,
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
    try {
      await methodChannel.invokeMethod('moveAppToFront', {"event": event});
    } on PlatformException catch (_) {
      return false;
    } on Exception catch (_) {
      return false;
    }
    return true;
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

  @override
  Future<void> openMicrophone() async {
    await methodChannel.invokeMethod('openMicrophone', {});
  }

  @override
  Future<void> closeMicrophone() async {
    await methodChannel.invokeMethod('closeMicrophone', {});
  }

  @override
  Future<void> apiLog(TRTCLoggerLevel level, String logString) async {
    await methodChannel.invokeMethod('apiLog', {'level': level.index, 'logString': logString});
  }

  @override
  Future<bool> hasPermissions(
      {required List<PermissionType> permissions}) async {
    List<int> permissionsList = [];
    for (var element in permissions) {
      permissionsList.add(element.index);
    }
    return await methodChannel
        .invokeMethod('hasPermissions', {'permission': permissionsList});
  }

  @override
  Future<PermissionResult> requestPermissions(
      {required List<PermissionType> permissions,
        String title = "",
        String description = "",
        String settingsTip = ""}) async {
    try {
      List<int> permissionsList = [];
      for (var element in permissions) {
        permissionsList.add(element.index);
      }
      int result = await methodChannel.invokeMethod('requestPermissions', {
        'permission': permissionsList,
        'title': title,
        'description': description,
        'settingsTip': settingsTip
      });
      if (result == PermissionResult.granted.index) {
        return PermissionResult.granted;
      } else if (result == PermissionResult.denied.index) {
        return PermissionResult.denied;
      } else {
        return PermissionResult.requesting;
      }
    } on PlatformException catch (_) {
      return PermissionResult.denied;
    } on Exception catch (_) {
      return PermissionResult.denied;
    }
  }

  void _handleNativeCall(MethodCall call) {
    debugPrint(
        "CallHandler method:${call.method}, arguments:${call.arguments}");
    switch (call.method) {
      case "backCallingPage":
        _handleBackCallingPage();
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
      case "appEnterForeground":
        _appEnterForeground();
        break;
      case "voipChangeMute":
        _handleVoipChangeMute(call);
        break;
      case "voipChangeAudioPlaybackDevice":
        _handleVoipChangeAudioPlaybackDevice(call);
        break;
      default:
        debugPrint("flutter: MethodNotImplemented ${call.method}");
        break;
    }
  }

  void _handleBackCallingPage() {
    CallManager.instance.backCallingPageFormFloatWindow();
  }

  void _handleCallReceived() {
    CallManager.instance.launchCallingPage();
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

  void _appEnterForeground() {
    CallManager.instance.handleAppEnterForeground();
  }

  void _handleVoipChangeMute(MethodCall call) {
    if (CallState.instance.selfUser.callStatus != TUICallStatus.none) {
      CallState.instance.isMicrophoneMute = call.arguments['mute'];
      TUICore.instance.notifyEvent(setStateEvent);
    }
  }

  void _handleVoipChangeAudioPlaybackDevice(MethodCall call) {
    if (CallState.instance.selfUser.callStatus != TUICallStatus.none) {
      CallState.instance.audioDevice = call.arguments['audioPlaybackDevice'];
      TUICore.instance.notifyEvent(setStateEvent);
    }
  }
}
