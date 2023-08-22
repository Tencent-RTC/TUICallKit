import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/extensions/calling_bell_feature.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/utils/event_bus.dart';
import 'package:tencent_calls_uikit/src/utils/preference_utils.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';

class CallState {
  static final CallState instance = CallState._internal();

  factory CallState() {
    return instance;
  }

  CallState._internal() {
    init();
  }

  User selfUser = User();
  User caller = User();
  List<User> calleeList = [];
  List<String> calleeIdList = [];
  List<User> remoteUserList = [];
  TUICallScene scene = TUICallScene.singleCall;
  TUICallMediaType mediaType = TUICallMediaType.none;
  int timeCount = 0;
  int startTime = 0;
  late Timer _timer;
  TUIRoomId roomId = TUIRoomId.intRoomId(intRoomId: 0);
  String groupId = '';
  bool isCameraOpen = false;
  TUICamera camera = TUICamera.front;
  bool isMicrophoneMute = false;
  TUIAudioPlaybackDevice audioDevice = TUIAudioPlaybackDevice.earpiece;
  bool enableMuteMode = false;
  bool enableFloatWindow = false;

  bool isChangedBigSmallVideo = false;

  TUICallObserver? observer;

  void init() {
    PreferenceUtils.getInstance()
        .getBool(Constants.spKeyEnableMuteMode, false)
        .then((value) => {enableMuteMode = value});
  }

  void registerEngineObserver() {
    observer ??= TUICallObserver(
        onError: (int code, String message) {
          TUIToast.show(content: 'Error: $code, $message');
        },
        onCallReceived: (String callerId, List<String> calleeIdList,
            String groupId, TUICallMediaType callMediaType) async {
          debugPrint("----------onCallReceived----------");
          CallState.instance.caller.id = callerId;
          CallState.instance.calleeIdList.clear();
          CallState.instance.calleeIdList.addAll(calleeIdList);
          CallState.instance.groupId = groupId;
          CallState.instance.mediaType = callMediaType;
          if (Platform.isAndroid &&
              !await TUICallKitPlatform.instance.isAppInForeground()) {
            await TUICallKitPlatform.instance
                .moveAppToFront("event_handle_receive_call");
          } else {
            handleCallReceived(callerId, calleeIdList, groupId, mediaType);
          }
        },
        onCallCancelled: (String callerId) {
          debugPrint("----------onCallCancelled----------");
          TUICallKitPlatform.instance.stopRing();
          cleanState();
          eventBus.notify(setStateEventOnCallEnd);
          TUICallKitPlatform.instance.updateCallStateToNative();
        },
        onCallBegin: (TUIRoomId roomId, TUICallMediaType callMediaType,
            TUICallRole callRole) {
          TUICallKitPlatform.instance.startForegroundService();
          debugPrint("----------onCallBegin----------");
          CallState.instance.startTime =
              DateTime.now().millisecondsSinceEpoch ~/ 1000;
          TUICallKitPlatform.instance.stopRing();
          CallState.instance.roomId = roomId;
          CallState.instance.mediaType = callMediaType;
          CallState.instance.selfUser.callRole = callRole;
          CallState.instance.selfUser.callStatus = TUICallStatus.accept;
          if (CallState.instance.isMicrophoneMute) {
            CallManager.instance.closeMicrophone();
          } else {
            CallManager.instance.openMicrophone();
          }
          CallManager.instance
              .selectAudioPlaybackDevice(CallState.instance.audioDevice);
          _startTimer();
          eventBus.notify(setStateEvent);
          eventBus.notify(setStateEventOnCallBegin);
          TUICallKitPlatform.instance.updateCallStateToNative();
        },
        onCallEnd: (TUIRoomId roomId, TUICallMediaType callMediaType,
            TUICallRole callRole, double totalTime) {
          debugPrint("----------onCallEnd----------");
          _stopTimer();
          cleanState();
          eventBus.notify(setStateEventOnCallEnd);
          TUICallKitPlatform.instance.updateCallStateToNative();
        },
        onCallMediaTypeChanged: (TUICallMediaType oldCallMediaType,
            TUICallMediaType newCallMediaType) {
          debugPrint("----------onCallMediaTypeChanged----------");
          CallState.instance.mediaType = newCallMediaType;
          eventBus.notify(setStateEvent);
          TUICallKitPlatform.instance.updateCallStateToNative();
        },
        onUserReject: (String userId) {
          debugPrint("----------onUserReject----------");
          for (var remoteUser in CallState.instance.remoteUserList) {
            if (remoteUser.id == userId) {
              CallState.instance.remoteUserList.remove(remoteUser);
              eventBus.notify(setStateEvent);
              break;
            }
          }

          if (CallState.instance.remoteUserList.isEmpty) {
            TUICallKitPlatform.instance.stopRing();
            cleanState();
            eventBus.notify(setStateEventOnCallEnd);
          }
          TUICallKitPlatform.instance.updateCallStateToNative();
          if (TUICallScene.singleCall == CallState.instance.scene) {
            TUIToast.show(content: CallKit_t('对方拒绝了通话请求'));
          } else {
            TUIToast.show(content: '$userId ${CallKit_t('拒绝了通话请求')}');
          }
        },
        onUserNoResponse: (String userId) {
          debugPrint("----------onUserNoResponse----------");
          for (var remoteUser in CallState.instance.remoteUserList) {
            if (remoteUser.id == userId) {
              CallState.instance.remoteUserList.remove(remoteUser);
              eventBus.notify(setStateEvent);
              break;
            }
          }

          if (CallState.instance.remoteUserList.isEmpty) {
            TUICallKitPlatform.instance.stopRing();
            cleanState();
            eventBus.notify(setStateEventOnCallEnd);
          }

          TUICallKitPlatform.instance.updateCallStateToNative();
          if (TUICallScene.singleCall == CallState.instance.scene) {
            TUIToast.show(content: CallKit_t('对方未响应'));
          } else {
            TUIToast.show(content: '$userId ${CallKit_t('未响应')}');
          }
        },
        onUserLineBusy: (String userId) {
          debugPrint("----------onUserLineBusy----------");
          for (var remoteUser in CallState.instance.remoteUserList) {
            if (remoteUser.id == userId) {
              CallState.instance.remoteUserList.remove(remoteUser);
              eventBus.notify(setStateEvent);
              break;
            }
          }

          if (CallState.instance.remoteUserList.isEmpty) {
            TUICallKitPlatform.instance.stopRing();
            cleanState();

            Timer.periodic(const Duration(milliseconds: 100), (timer) {
              eventBus.notify(setStateEventOnCallEnd);
              timer.cancel();
            });
          }

          TUICallKitPlatform.instance.updateCallStateToNative();

          if (TUICallScene.singleCall == CallState.instance.scene) {
            TUIToast.show(content: CallKit_t('对方忙线'));
          } else {
            TUIToast.show(content: '$userId ${CallKit_t('忙线')}');
          }
        },
        onUserJoin: (String userId) async {
          debugPrint("onUserJoin: userId -> $userId");
          for (var remoteUser in CallState.instance.remoteUserList) {
            if (remoteUser.id == userId) {
              remoteUser.callStatus = TUICallStatus.accept;
              eventBus.notify(setStateEvent);

              TUICallKitPlatform.instance.updateCallStateToNative();
              return;
            }
          }

          TUICallKitPlatform.instance.stopRing();

          final user = User();
          user.id = userId;
          user.callStatus == TUICallStatus.accept;
          CallState.instance.remoteUserList.add(user);
          final imInfo = await TencentImSDKPlugin.v2TIMManager
              .getUsersInfo(userIDList: [userId]);
          user.nickname = StringStream.makeNull(
              imInfo.data?[0].nickName, Constants.defaultNickname);
          user.avatar = StringStream.makeNull(
              imInfo.data?[0].faceUrl, Constants.defaultAvatar);
          eventBus.notify(setStateEvent);

          TUICallKitPlatform.instance.updateCallStateToNative();
        },
        onUserLeave: (String userId) {
          debugPrint("----------onUserLeave: userId -> $userId----------");
          for (var remoteUser in CallState.instance.remoteUserList) {
            if (remoteUser.id == userId) {
              CallState.instance.remoteUserList.remove(remoteUser);
              eventBus.notify(setStateEvent);
              break;
            }
          }

          if (CallState.instance.remoteUserList.isEmpty) {
            cleanState();
            eventBus.notify(setStateEventOnCallEnd);
          }

          TUICallKitPlatform.instance.updateCallStateToNative();

          if (TUICallScene.singleCall == CallState.instance.scene) {
            TUIToast.show(content: CallKit_t('对方已挂断，通话结束'));
          } else {
            TUIToast.show(content: '$userId ${CallKit_t('结束了通话')}');
          }
        },
        onUserVideoAvailable: (String userId, bool isVideoAvailable) {
          debugPrint(
              "onUserVideoAvailable:$userId isVideoAvailable:$isVideoAvailable");
          for (var remoteUser in CallState.instance.remoteUserList) {
            if (remoteUser.id == userId) {
              remoteUser.videoAvailable = isVideoAvailable;
              eventBus.notify(setStateEvent);

              TUICallKitPlatform.instance.updateCallStateToNative();
              return;
            }
          }
        },
        onUserAudioAvailable: (String userId, bool isAudioAvailable) {
          for (var remoteUser in CallState.instance.remoteUserList) {
            if (remoteUser.id == userId) {
              remoteUser.audioAvailable = isAudioAvailable;
              eventBus.notify(setStateEvent);
              return;
            }
          }
        },
        onUserNetworkQualityChanged:
            (List<TUINetworkQualityInfo> networkQualityList) {},
        onUserVoiceVolumeChanged: (Map<String, int> volumeMap) {
          for (var remoteUser in CallState.instance.remoteUserList) {
            remoteUser.playOutVolume = volumeMap[remoteUser.id] ?? 0;
          }
        },
        onKickedOffline: () {
          debugPrint("----------onKickedOffline----------");
          CallManager.instance.hangup();
          cleanState();
          eventBus.notify(setStateEvent);
          TUICallKitPlatform.instance.stopRing();
          TUICallKitPlatform.instance.updateCallStateToNative();
        },
        onUserSigExpired: () {
          debugPrint("----------onUserSigExpired----------");
          CallManager.instance.hangup();
          cleanState();
          eventBus.notify(setStateEvent);
          TUICallKitPlatform.instance.stopRing();
          TUICallKitPlatform.instance.updateCallStateToNative();
        });
    TUICallEngine.instance.addObserver(observer!);
  }

  void unRegisterEngineObserver() {
    if (observer != null) {
      TUICallEngine.instance.removeObserver(observer!);
    }
  }

  void handleCallReceived(String callerId, List<String> calleeIdList,
      String groupId, TUICallMediaType callMediaType) async {
    if (callMediaType == TUICallMediaType.none || calleeIdList.isEmpty) {
      return;
    }

    if (calleeIdList.length >= Constants.groupCallMaxUserCount) {
      TUIToast.show(content: CallKit_t('超过最大人数限制'));
      return;
    }

    CallState.instance.groupId = groupId;
    if (CallState.instance.groupId.isNotEmpty) {
      CallState.instance.scene = TUICallScene.groupCall;
    } else if (CallState.instance.calleeList.isNotEmpty &&
        CallState.instance.calleeList.length > 1) {
      CallState.instance.scene = TUICallScene.multiCall;
    } else {
      CallState.instance.scene = TUICallScene.singleCall;
    }
    CallState.instance.mediaType = callMediaType;

    CallState.instance.selfUser.callStatus = TUICallStatus.waiting;
    CallState.instance.selfUser.callRole = TUICallRole.called;
    CallingBellFeature.startRing();

    final allUserId = [callerId] + calleeIdList;

    for (var userId in allUserId) {
      if (CallState.instance.selfUser.id == userId) {
        if (userId == callerId) {
          CallState.instance.caller = CallState.instance.selfUser;
        } else {
          CallState.instance.calleeList.add(CallState.instance.selfUser);
        }
        continue;
      }

      final user = User();
      user.id = userId;

      if (userId == callerId) {
        CallState.instance.caller = user;
      } else {
        CallState.instance.calleeList.add(user);
      }
      CallState.instance.remoteUserList.add(user);
    }

    final imUserList = await TencentImSDKPlugin.v2TIMManager
        .getUsersInfo(userIDList: allUserId);

    for (var imUser in imUserList.data!) {
      if (imUser.userID == CallState.instance.selfUser.id) {
        continue;
      }

      if (imUser.userID == callerId) {
        CallState.instance.caller.nickname =
            StringStream.makeNull(imUser.nickName, Constants.defaultNickname);
        CallState.instance.caller.avatar =
            StringStream.makeNull(imUser.faceUrl, Constants.defaultAvatar);
        CallState.instance.caller.callStatus = TUICallStatus.waiting;
        CallState.instance.caller.callRole = (imUser.userID == callerId)
            ? TUICallRole.caller
            : TUICallRole.called;
      } else {
        for (var remoteUser in CallState.instance.remoteUserList) {
          if (remoteUser.id == imUser.userID) {
            remoteUser.nickname = StringStream.makeNull(
                imUser.nickName, Constants.defaultNickname);
            remoteUser.avatar =
                StringStream.makeNull(imUser.faceUrl, Constants.defaultAvatar);
            remoteUser.callStatus = TUICallStatus.waiting;
            remoteUser.callRole = (imUser.userID == callerId)
                ? TUICallRole.caller
                : TUICallRole.called;
          }
        }
      }

      for (var caller in CallState.instance.calleeList) {
        if (caller.id == imUser.userID) {
          caller.nickname =
              StringStream.makeNull(imUser.nickName, Constants.defaultNickname);
          caller.avatar =
              StringStream.makeNull(imUser.faceUrl, Constants.defaultAvatar);
          caller.callStatus = TUICallStatus.waiting;
          caller.callRole = (imUser.userID == callerId)
              ? TUICallRole.caller
              : TUICallRole.called;
        }
      }
    }
    CallManager.instance.initAudioPlayDevice();
    eventBus.notify(setStateEventOnCallReceived);
    TUICallKitPlatform.instance.updateCallStateToNative();
  }

  void _startTimer() {
    CallState.instance.timeCount = 0;
    CallState.instance._timer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (TUICallStatus.accept != CallState.instance.selfUser.callStatus) {
        _stopTimer();
        return;
      }
      CallState.instance.timeCount++;
      eventBus.notify(setStateEventRefreshTiming);
    });
  }

  void _stopTimer() {
    CallState.instance._timer.cancel();
  }

  void cleanState() {
    CallState.instance.selfUser.callRole = TUICallRole.none;
    CallState.instance.selfUser.callStatus = TUICallStatus.none;

    CallState.instance.remoteUserList.clear();
    CallState.instance.caller = User();
    CallState.instance.calleeList.clear();

    CallState.instance.mediaType = TUICallMediaType.none;
    CallState.instance.timeCount = 0;
    CallState.instance.roomId = TUIRoomId.intRoomId(intRoomId: 0);
    CallState.instance.groupId = '';

    CallState.instance.isMicrophoneMute = false;
    CallState.instance.camera = TUICamera.front;
    CallState.instance.isCameraOpen = false;
    CallState.instance.audioDevice = TUIAudioPlaybackDevice.earpiece;

    CallState.instance.isChangedBigSmallVideo = false;
  }
}
