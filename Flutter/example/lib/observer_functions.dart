import 'package:flutter/cupertino.dart';
import 'package:tencent_calls_engine/tuicall_engine.dart';
import 'package:tencent_calls_engine/tuicall_observer.dart';
import 'package:tencent_calls_engine/tuicall_define.dart';

/// 设置回调
void setObserverFubction({required TUICallEngine callsEnginePlugin}) {
  callsEnginePlugin.addObserver(TUICallObserver(onError:
      (int code, String message) {
    debugPrint('------------------------------------------------onError');
  }, onCallCancelled: (String callerId) {
    debugPrint(
        '+++------------------------------------------------onCallCancelled');
  }, onCallBegin:
      (TUIRoomId roomId, TUICallMediaType callMediaType, TUICallRole callRole) {
    debugPrint('------------------------------------------------onCallBegin');
  }, onCallEnd: (TUIRoomId roomId, TUICallMediaType callMediaType,
      TUICallRole callRole, double totalTime) {
    debugPrint('------------------------------------------------onCallEnd');
  }, onCallMediaTypeChanged:
      (TUICallMediaType oldCallMediaType, TUICallMediaType newCallMediaType) {
    debugPrint(
        '------------------------------------------------onCallMediaTypeChanged');
  }, onUserReject: (String userId) {
    debugPrint(
        '+++------------------------------------------------onUserReject');
  }, onUserNoResponse: (String userId) {
    debugPrint(
        '+++------------------------------------------------onUserNoResponse');
  }, onUserLineBusy: (String onUserLineBusy) {
    debugPrint(
        '+++------------------------------------------------onUserLineBusy');
  }, onUserJoin: (String userId) {
    debugPrint('+++------------------------------------------------onUserJoin');
  }, onUserLeave: (String userId) {
    debugPrint(
        '+++------------------------------------------------onUserLeave');
  }, onUserVideoAvailable: (String userId, bool isVideoAvailable) {
    debugPrint(
        '------------------------------------------------onUserVideoAvailable');
  }, onUserAudioAvailable: (String userId, bool isAudioAvailable) {
    debugPrint(
        '------------------------------------------------onUserAudioAvailable');
  }, onUserNetworkQualityChanged:
      (List<TUINetworkQualityInfo> networkQualityList) {
    debugPrint(
        '------------------------------------------------onUserNetworkQualityChanged');
  }, onCallReceived: (String callerId, List<String> calleeIdList,
      String groupId, TUICallMediaType callMediaType) {
    debugPrint(
        '------------------------------------------------onCallReceived');
  }, onUserVoiceVolumeChanged: (Map<String, int> volumeMap) {
    debugPrint(
        '------------------------------------------------onUserVoiceVolumeChanged');
  }, onKickedOffline: () {
    debugPrint(
        '------------------------------------------------onKickedOffline');
  }, onUserSigExpired: () {
    debugPrint(
        '------------------------------------------------onUserSigExpired');
  }));
}
