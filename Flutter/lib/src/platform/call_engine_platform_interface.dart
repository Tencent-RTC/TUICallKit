// Copyright (c) 2021 Tencent. All rights reserved.
// Author: tatemin

import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tencent_calls_uikit/src/platform/call_engine_method_channel.dart';
import 'package:tencent_calls_uikit/src/call_define.dart';
import 'package:tencent_calls_uikit/src/call_observer.dart';

abstract class TUICallEnginePlatform extends PlatformInterface {
  /// Constructs a TuicallEnginePlatform.
  TUICallEnginePlatform() : super(token: _token);

  static final Object _token = Object();

  static TUICallEnginePlatform _instance = MethodChannelTUICallEngine();

  /// The default instance of [TUICallEnginePlatform] to use.
  ///
  /// Defaults to [MethodChannelTUICallEngine].
  static TUICallEnginePlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [TUICallEnginePlatform] when
  /// they register themselves.
  static set instance(TUICallEnginePlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> addObserver(TUICallObserver observer) async {
    await _instance.addObserver(observer);
  }

  Future<void> removeObserver(TUICallObserver observer) async {
    await _instance.removeObserver(observer);
  }

  Future<TUIResult> setVideoEncoderParams(VideoEncoderParams params) async {
    return await _instance.setVideoEncoderParams(params);
  }

  Future<TUIResult> setVideoRenderParams(
      String userId, VideoRenderParams params) async {
    return await _instance.setVideoRenderParams(userId, params);
  }

  Future<TUIResult> hangup() async {
    return await _instance.hangup();
  }

  Future<TUIResult> init(int sdkAppID, String userId, String userSig) async {
    return await _instance.init(sdkAppID, userId, userSig);
  }

  Future<TUIResult> unInit() async {
    return await TUICallEnginePlatform.instance.unInit();
  }

  Future<TUIResult> calls(
      List<String> userIdList, TUICallMediaType mediaType, TUICallParams params) async {
    return await _instance.calls(userIdList, mediaType, params);
  }

  Future<TUIResult> call(
      String userId, TUICallMediaType mediaType, TUICallParams params) async {
    return await _instance.call(userId, mediaType, params);
  }

  Future<TUIResult> groupCall(String groupId, List<String> userIdList,
      TUICallMediaType mediaType, TUICallParams params) async {
    return await _instance.groupCall(groupId, userIdList, mediaType, params);
  }

  Future<TUIResult> accept() async {
    return await _instance.accept();
  }

  Future<TUIResult> reject() async {
    return await _instance.reject();
  }

  Future<TUIResult> ignore() async {
    return await _instance.ignore();
  }

  Future<void> iniviteUser(List<String> userIdList, TUICallParams params,
      TUIValueCallback callback) async {
    return await _instance.iniviteUser(userIdList, params, callback);
  }

  Future<TUIResult> join(String callId) async {
    return await _instance.join(callId);
  }

  Future<TUIResult> joinInGroupCall(
      TUIRoomId roomId, String groupId, TUICallMediaType mediaType) async {
    return await _instance.joinInGroupCall(roomId, groupId, mediaType);
  }

  Future<void> switchCallMediaType(TUICallMediaType mediaType) async {
    await _instance.switchCallMediaType(mediaType);
  }

  Future<void> startRemoteView(String userId, int? viewId) async {
    await _instance.startRemoteView(userId, viewId);
  }

  Future<void> stopRemoteView(String userId) async {
    await _instance.stopRemoteView(userId);
  }

  Future<TUIResult> openCamera(TUICamera camera, int? viewId) async {
    return await _instance.openCamera(camera, viewId);
  }

  Future<void> closeCamera() async {
    await _instance.closeCamera();
  }

  Future<void> switchCamera(TUICamera camera) async {
    await _instance.switchCamera(camera);
  }

  Future<TUIResult> openMicrophone() async {
    return await _instance.openMicrophone();
  }

  Future<void> closeMicrophone() async {
    await _instance.closeMicrophone();
  }

  Future<void> selectAudioPlaybackDevice(TUIAudioPlaybackDevice device) async {
    await _instance.selectAudioPlaybackDevice(device);
  }

  Future<TUIResult> setSelfInfo(String nickname, String avatar) async {
    return await _instance.setSelfInfo(nickname, avatar);
  }

  Future<TUIResult> enableMultiDeviceAbility(bool enable) async {
    return await _instance.enableMultiDeviceAbility(enable);
  }

  Future<void> queryRecentCalls(
      TUICallRecentCallsFilter filter, TUIValueCallback callback) async {
    return await _instance.queryRecentCalls(filter, callback);
  }

  Future<void> deleteRecordCalls(
      List<String> callIdList, TUIValueCallback callback) async {
    return await _instance.deleteRecordCalls(callIdList, callback);
  }

  Future<TUIResult> setBeautyLevel(double level) async {
    return await _instance.setBeautyLevel(level);
  }

  void setBlurBackground(int level, Function(int code, String message)? errorCallback) async {
    _instance.setBlurBackground(level, errorCallback);
  }

  void setVirtualBackground(String imagePath, Function(int code, String message)? errorCallback) async {
    _instance.setVirtualBackground(imagePath, errorCallback);
  }

  Future<void> callExperimentalAPI(Map<String, dynamic> jsonMap) async {
    await _instance.callExperimentalAPI(jsonMap);
  }
}
