import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';
import 'package:tuicall_kit_example/src/login_widget.dart';

void setObserverFunction({required TUICallEngine callsEnginePlugin}) {
  callsEnginePlugin.addObserver(TUICallObserver(onError: (int code, String message) {
    debugPrint('------------------------------------------------onError');
  }, onCallNotConnected: (String callId, TUICallMediaType mediaType, CallEndReason reason,
      String userId, CallObserverExtraInfo info) {
    debugPrint('------------------------------------------------onCallNotConnected');
  }, onCallBegin: (String callId, TUICallMediaType mediaType, CallObserverExtraInfo info) {
    debugPrint('------------------------------------------------onCallBegin');
  }, onCallEnd: (String callId, TUICallMediaType mediaType, CallEndReason reason,
      String userId, double totalTime, CallObserverExtraInfo info) {
    debugPrint('------------------------------------------------onCallEnd');
  }, onCallMediaTypeChanged:
      (TUICallMediaType oldCallMediaType, TUICallMediaType newCallMediaType) {
    debugPrint('------------------------------------------------onCallMediaTypeChanged');
  }, onUserReject: (String userId) {
    debugPrint('+++------------------------------------------------onUserReject');
  }, onUserNoResponse: (String userId) {
    debugPrint('+++------------------------------------------------onUserNoResponse');
  }, onUserLineBusy: (String onUserLineBusy) {
    debugPrint('+++------------------------------------------------onUserLineBusy');
  }, onUserJoin: (String userId) {
    debugPrint('+++------------------------------------------------onUserJoin');
  }, onUserLeave: (String userId) {
    debugPrint('+++------------------------------------------------onUserLeave');
  }, onUserVideoAvailable: (String userId, bool isVideoAvailable) {
    debugPrint('------------------------------------------------onUserVideoAvailable');
  }, onUserAudioAvailable: (String userId, bool isAudioAvailable) {
    debugPrint('------------------------------------------------onUserAudioAvailable');
  }, onUserNetworkQualityChanged: (List<TUINetworkQualityInfo> networkQualityList) {
    debugPrint('------------------------------------------------onUserNetworkQualityChanged');
  }, onCallReceived: (String callId, String callerId, List<String> calleeIdList, TUICallMediaType mediaType, CallObserverExtraInfo info) {
    debugPrint('------------------------------------------------onCallReceived');
  }, onUserVoiceVolumeChanged: (Map<String, int> volumeMap) {
    debugPrint('------------------------------------------------onUserVoiceVolumeChanged');
  }, onKickedOffline: () {
    debugPrint('------------------------------------------------onKickedOffline');
    TUICallKit.navigatorObserver.navigator?.pushAndRemoveUntil(MaterialPageRoute(builder: (widget) {
      return const LoginWidget();
    }), (route) => false);
  }, onUserSigExpired: () {
    debugPrint('------------------------------------------------onUserSigExpired');
    TUICallKit.navigatorObserver.navigator?.pushAndRemoveUntil(MaterialPageRoute(builder: (widget) {
      return const LoginWidget();
    }), (route) => false);
  }));
}
