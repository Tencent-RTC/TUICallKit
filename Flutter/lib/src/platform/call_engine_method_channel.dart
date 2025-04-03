// Copyright (c) 2021 Tencent. All rights reserved.
// Author: tatemin

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:tencent_calls_uikit/src/platform/call_engine_platform_interface.dart';
import 'package:tencent_calls_uikit/src/call_observer.dart';
import 'package:tencent_calls_uikit/src/call_define.dart';

/// An implementation of [TUICallEnginePlatform] that uses method channels.
class MethodChannelTUICallEngine extends TUICallEnginePlatform {
  final List<TUICallObserver> _observerList = [];
  @visibleForTesting
  static const methodChannel = MethodChannel('tuicall_kit_engine');

  MethodChannelTUICallEngine() {
    methodChannel.setMethodCallHandler((call) async {
      if (call.method == "onTUICallObserver") {
        String observerName = call.arguments['method'];
        var observerParams = call.arguments['params'];
        _onTUICallObserver(observerName, observerParams);
      } else {
        debugPrint("onTUICallObserver: MethodNotImplemented ${call.arguments}");
      }
    });
  }

  @override
  Future<void> addObserver(TUICallObserver observer) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      if (_observerList.contains(observer)) {
        return;
      }
      _observerList.add(observer);
      methodChannel.invokeMethod("addObserver", {});
    }
  }

  @override
  Future<void> removeObserver(TUICallObserver observer) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      _observerList.remove(observer);
      if (_observerList.isEmpty) {
        methodChannel.invokeMethod("removeObserver", {});
      }
    }
  }

  @override
  Future<void> removeAllObserver() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      _observerList.clear();
      methodChannel.invokeMethod("removeObserver", {});
    }
  }

  @override
  Future<TUIResult> setVideoEncoderParams(VideoEncoderParams params) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod("setVideoEncoderParams", {"params": params.toJson()});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "setVideoEncoderParams success");
  }

  @override
  Future<TUIResult> setVideoRenderParams(String userId, VideoRenderParams params) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod(
            "setVideoRenderParams", {"userId": userId, "params": params.toJson()});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "setVideoRenderParams success");
  }

  @override
  Future<TUIResult> hangup() async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod("hangup", {});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "hangup success");
  }

  @override
  Future<TUIResult> init(int sdkAppID, String userId, String userSig) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod(
            "init", {'sdkAppID': sdkAppID, 'userId': userId, 'userSig': userSig});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "init success");
  }

  @override
  Future<TUIResult> unInit() async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod("unInit", {});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "unInit success");
  }

  @override
  Future<TUIResult> calls(List<String> userIdList, TUICallMediaType mediaType, TUICallParams params) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel
            .invokeMethod(
            "calls", {'userIdList': userIdList, 'mediaType': mediaType.index, 'params': params.toJson()});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "call success");
  }

  @override
  Future<TUIResult> call(String userId, TUICallMediaType mediaType, TUICallParams params) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel
            .invokeMethod(
            "call", {'userId': userId, 'mediaType': mediaType.index, 'params': params.toJson()});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "call success");
  }

  @override
  Future<TUIResult> groupCall(
      String groupId, List<String> userIdList, TUICallMediaType mediaType, TUICallParams params) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod("groupCall",
            {
              'groupId': groupId,
              'userIdList': userIdList,
              'mediaType': mediaType.index,
              'params': params.toJson()
            });
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "groupCall success");
  }

  @override
  Future<TUIResult> accept() async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod("accept", {});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "accept success");
  }

  @override
  Future<TUIResult> reject() async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod("reject", {});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "reject success");
  }

  @override
  Future<TUIResult> ignore() async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod("ignore", {});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "ignore success");
  }

  @override
  Future<void> iniviteUser(List<String> userIdList, TUICallParams params, TUIValueCallback callback) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        var userIds =
        await methodChannel.invokeMethod(
            "iniviteUser", {'userIdList': userIdList, 'params': params.toJson()});
        callback.onSuccess!(userIds);
      } else {
        callback.onError!(-1, 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      callback.onError!(int.fromEnvironment(error.code), error.message!);
    } on Exception catch (error) {
      callback.onError!(-1, error.toString());
    }
  }

  @override
  Future<TUIResult> join(String callId) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod(
            "join", {'callId': callId});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "join success");
  }

  @override
  Future<TUIResult> joinInGroupCall(TUIRoomId roomId, String groupId, TUICallMediaType mediaType) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod(
            "joinInGroupCall",
            {'roomId': roomId.toJson(), 'groupId': groupId, 'mediaType': mediaType.index});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "joinInGroupCall success");
  }

  @override
  Future<void> switchCallMediaType(TUICallMediaType mediaType) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod("switchCallMediaType", {'mediaType': mediaType.index});
    }
  }

  @override
  Future<void> startRemoteView(String userId, int? viewId) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod("startRemoteView", {'userId': userId, 'viewId': viewId});
    }
  }

  @override
  Future<void> stopRemoteView(String userId) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod("stopRemoteView", {'userId': userId});
    }
  }

  @override
  Future<TUIResult> openCamera(TUICamera camera, int? viewId) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod("openCamera", {'camera': camera.index, 'viewId': viewId});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "openCamera success");
  }

  @override
  Future<void> closeCamera() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod("closeCamera", {});
    }
  }

  @override
  Future<void> switchCamera(TUICamera camera) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod("switchCamera", {'camera': camera.index});
    }
  }

  @override
  Future<TUIResult> openMicrophone() async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod("openMicrophone", {});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "openMicrophone success");
  }

  @override
  Future<void> closeMicrophone() async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod("closeMicrophone", {});
    }
  }

  @override
  Future<void> selectAudioPlaybackDevice(TUIAudioPlaybackDevice device) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod("selectAudioPlaybackDevice", {'device': device.index});
    }
  }

  @override
  Future<TUIResult> setSelfInfo(String nickname, String avatar) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod("setSelfInfo", {'nickname': nickname, 'avatar': avatar});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "setSelfInfo success");
  }

  @override
  Future<TUIResult> enableMultiDeviceAbility(bool enable) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod("enableMultiDeviceAbility", {'enable': enable});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "enableMultiDeviceAbility success");
  }

  @override
  Future<void> queryRecentCalls(TUICallRecentCallsFilter filter, TUIValueCallback callback) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        var result = await methodChannel.invokeMethod(
            "queryRecentCalls", {'filter': filter.toJson()});
        List<TUICallRecords> callRecords = [];
        final recordList = List<dynamic>.from(result);
        for (var recordMap in recordList) {
          TUICallRecords record = TUICallRecords();
          record.callId = recordMap['callId'];
          record.inviter = recordMap['inviter'];
          record.inviteList = List<String>.from(recordMap['inviteList']);
          record.scene = TUICallScene.values[recordMap['scene']];
          record.mediaType = TUICallMediaType.values[recordMap['mediaType']];
          record.groupId = recordMap['groupId'];
          record.role = TUICallRole.values[recordMap['role']];
          record.result = TUICallResultType.values[recordMap['result']];
          record.beginTime = recordMap['beginTime'];
          record.totalTime = recordMap['totalTime'];
          callRecords.add(record);
        }
        callback.onSuccess!(result);
      } else {
        callback.onError!(-1, 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      callback.onError!(int.fromEnvironment(error.code), error.message!);
    } on Exception catch (error) {
      callback.onError!(-1, error.toString());
    }
  }

  @override
  Future<void> deleteRecordCalls(
    List<String> callIdList,
    TUIValueCallback callback,
  ) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        var callIds = await methodChannel.invokeMethod(
            "deleteRecordCalls", {'callIdList': callIdList});
        callback.onSuccess!(callIds);
      } else {
        callback.onError!(-1, 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      callback.onError!(int.fromEnvironment(error.code), error.message!);
    } on Exception catch (error) {
      callback.onError!(-1, error.toString());
    }
  }

  @override
  Future<TUIResult> setBeautyLevel(double level) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod("setBeautyLevel", {'level': level});
      } else {
        return TUIResult(code: "-1", message: 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      return TUIResult(code: error.code, message: error.message);
    } on Exception catch (error) {
      return TUIResult(code: "-1", message: error.toString());
    }
    return TUIResult(code: "", message: "setBeautyLevel success");
  }

  @override
  void setBlurBackground(int level, Function(int code, String message)? errorCallback) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod("setBlurBackground", {'level': level});
      } else {
        errorCallback!(-1, 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      errorCallback!(int.fromEnvironment(error.code), error.message!);
    } on Exception catch (error) {
      errorCallback!(-1, error.toString());
    }
  }

  @override
  void setVirtualBackground(String imagePath, Function(int code, String message)? errorCallback) async {
    try {
      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        await methodChannel.invokeMethod("setVirtualBackground", {'imagePath': imagePath});
      } else {
        errorCallback!(-1, 'This platform is not supported');
      }
    } on PlatformException catch (error) {
      errorCallback!(int.fromEnvironment(error.code), error.message!);
    } on Exception catch (error) {
      errorCallback!(-1, error.toString());
    }
  }

  @override
  Future<void> callExperimentalAPI(Map<String, dynamic> jsonMap) async {
    if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
      await methodChannel.invokeMethod("callExperimentalAPI", {'jsonMap': jsonMap});
    }
  }

  void _onTUICallObserver(String observerName, var params) {
    for (var observer in _observerList) {
      switch (observerName) {
        case "onError":
          {
            observer.onError != null ? observer.onError!(params["code"], params['message']) : false;
            break;
          }

        case "onUserInviting":
          {
            observer.onUserInviting != null ? observer.onUserInviting!(params['userId']) : false;
            break;
          }

        case "onCallReceived":
          {
            final callId = params['callId'];
            final callerId = params['callerId'];
            final calleeIdList = List<String>.from(params['calleeIdList']);
            TUICallMediaType mediaType = TUICallMediaType.values[params['mediaType']];
            CallObserverExtraInfo info = CallObserverExtraInfo.fromJson(params['info']);
            observer.onCallReceived != null
                ? observer.onCallReceived!(callId, callerId, calleeIdList, mediaType, info)
                : false;
            break;
          }

        case "onCallCancelled":
          {
            observer.onCallCancelled != null ? observer.onCallCancelled!(params['callerId']) : false;
            break;
          }

        case "onCallNotConnected":
          {
            final callId = params['callId'];
            TUICallMediaType mediaType = TUICallMediaType.values[params['mediaType']];
            CallEndReason reason = CallEndReason.values[params['reason']];
            final userId = params['userId'];
            CallObserverExtraInfo info = CallObserverExtraInfo.fromJson(params['info']);
            observer.onCallNotConnected != null ? observer.onCallNotConnected!(callId, mediaType, reason, userId, info) : false;
            break;
          }

        case "onCallBegin":
          {
            final callId = params['callId'];
            TUICallMediaType mediaType = TUICallMediaType.values[params['mediaType']];
            CallObserverExtraInfo info = CallObserverExtraInfo.fromJson(params['info']);
            observer.onCallBegin != null ? observer.onCallBegin!(callId, mediaType, info) : false;
            break;
          }

        case "onCallEnd":
          {
            final callId = params['callId'];
            TUICallMediaType mediaType = TUICallMediaType.values[params['mediaType']];
            CallEndReason reason = CallEndReason.values[params['reason']];
            final userId = params['userId'];
            double totalTime = params['totalTime'];
            CallObserverExtraInfo info = CallObserverExtraInfo.fromJson(params['info']);
            observer.onCallEnd != null ? observer.onCallEnd!(callId, mediaType, reason, userId, totalTime, info) : false;
            break;
          }

        case "onCallMediaTypeChanged":
          {
            TUICallMediaType oldCallMediaType = TUICallMediaType.values[params['oldCallMediaType']];
            TUICallMediaType newCallMediaType = TUICallMediaType.values[params['newCallMediaType']];
            observer.onCallMediaTypeChanged != null
                ? observer.onCallMediaTypeChanged!(oldCallMediaType, newCallMediaType)
                : false;
            break;
          }

        case "onUserReject":
          {
            observer.onUserReject != null ? observer.onUserReject!(params['userId']) : false;
            break;
          }

        case "onUserNoResponse":
          {
            observer.onUserNoResponse != null ? observer.onUserNoResponse!(params['userId']) : false;
            break;
          }

        case "onUserLineBusy":
          {
            observer.onUserLineBusy != null ? observer.onUserLineBusy!(params['userId']) : false;
            break;
          }

        case "onUserJoin":
          {
            observer.onUserJoin != null ? observer.onUserJoin!(params['userId']) : false;
            break;
          }

        case "onUserLeave":
          {
            observer.onUserLeave != null ? observer.onUserLeave!(params['userId']) : false;
            break;
          }

        case "onUserVideoAvailable":
          {
            observer.onUserVideoAvailable != null
                ? observer.onUserVideoAvailable!(params['userId'], params['isVideoAvailable'])
                : false;
            break;
          }

        case "onUserAudioAvailable":
          {
            observer.onUserAudioAvailable != null
                ? observer.onUserAudioAvailable!(params['userId'], params['isAudioAvailable'])
                : false;
            break;
          }

        case "onUserVoiceVolumeChanged":
          {
            final volumeMap = Map<String, int>.from(params['volumeMap']);
            observer.onUserVoiceVolumeChanged != null ? observer.onUserVoiceVolumeChanged!(volumeMap) : false;
            break;
          }

        case "onUserNetworkQualityChanged":
          {
            List returnNetworkQualityList = params['networkQualityList'];
            List<TUINetworkQualityInfo> networkQualityLists = [];
            for (final element in returnNetworkQualityList) {
              var userId = (element['userId'] == null) ? "" : element['userId'];
              TUINetworkQuality quality = TUINetworkQuality.values[element["networkQuality"]];
              networkQualityLists.add(TUINetworkQualityInfo(userId: userId, quality: quality));
            }
            observer.onUserNetworkQualityChanged != null
                ? observer.onUserNetworkQualityChanged!(networkQualityLists)
                : false;
            break;
          }

        case "onKickedOffline":
          {
            observer.onKickedOffline != null ? observer.onKickedOffline!() : false;
            break;
          }

        case "onUserSigExpired":
          {
            observer.onUserSigExpired != null ? observer.onUserSigExpired!() : false;
            break;
          }
      }
    }
  }
}
