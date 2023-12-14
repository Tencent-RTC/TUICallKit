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

//
typedef NickNameCallback = Future<String?> Function(String userId);

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

  // 新增获取nickName
  NickNameCallback? nameCallback;

  void setNameCallback({NickNameCallback? nameCallback}) {
    this.nameCallback = nameCallback;
  }

  TUICallObserver observer = TUICallObserver(
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
        CallState.instance.selfUser.callStatus = TUICallStatus.waiting;
        if (!await TUICallKitPlatform.instance.isAppInForeground()) {
          if (Platform.isAndroid) {
            await TUICallKitPlatform.instance.moveAppToFront("event_handle_receive_call");
          }
        } else {
          CallState.instance.handleCallReceived(callerId, calleeIdList, groupId, CallState.instance.mediaType);
        }
      },
      onCallCancelled: (String callerId) {
        debugPrint("----------onCallCancelled----------");
        TUICallKitPlatform.instance.stopRing();
        CallState.instance.cleanState();
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
        CallState.instance.startTimer();
        eventBus.notify(setStateEvent);
        eventBus.notify(setStateEventOnCallBegin);
        TUICallKitPlatform.instance.updateCallStateToNative();
      },
      onCallEnd: (TUIRoomId roomId, TUICallMediaType callMediaType,
          TUICallRole callRole, double totalTime) {
        debugPrint("----------onCallEnd----------");
        CallState.instance.stopTimer();
        CallState.instance.cleanState();
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
      onUserReject: (String userId) async {
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
          CallState.instance.cleanState();
          eventBus.notify(setStateEventOnCallEnd);
        }
        TUICallKitPlatform.instance.updateCallStateToNative();
        if (TUICallScene.singleCall == CallState.instance.scene) {
          TUIToast.show(content: CallKit_t('对方拒绝了通话请求'));
        } else {
          String? nickName =
              await CallState.instance.nameCallback?.call(userId) ?? userId;
          TUIToast.show(content: '$nickName ${CallKit_t('拒绝了通话请求')}');
        }
      },
      onUserNoResponse: (String userId) async {
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
          CallState.instance.cleanState();
          eventBus.notify(setStateEventOnCallEnd);
        }

        TUICallKitPlatform.instance.updateCallStateToNative();
        if (TUICallScene.singleCall == CallState.instance.scene) {
          TUIToast.show(content: CallKit_t('对方未响应'));
        } else {
          String? nickName =
              await CallState.instance.nameCallback?.call(userId) ?? userId;
          TUIToast.show(content: '$nickName ${CallKit_t('未响应')}');
        }
      },
      onUserLineBusy: (String userId) async {
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
          CallState.instance.cleanState();

          Timer.periodic(const Duration(milliseconds: 100), (timer) {
            eventBus.notify(setStateEventOnCallEnd);
            timer.cancel();
          });
        }

        TUICallKitPlatform.instance.updateCallStateToNative();

        if (TUICallScene.singleCall == CallState.instance.scene) {
          TUIToast.show(content: CallKit_t('对方忙线'));
        } else {
          String? nickName =
              await CallState.instance.nameCallback?.call(userId) ?? userId;
          TUIToast.show(content: '$nickName ${CallKit_t('忙线')}');
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
            .getFriendshipManager()
            .getFriendsInfo(userIDList: [userId]);
        user.nickname =
            StringStream.makeNull(imInfo.data?[0].friendInfo?.userProfile?.nickName, '');
        user.remark = StringStream.makeNull(imInfo.data?[0].friendInfo?.friendRemark, '');
        user.avatar = StringStream.makeNull(
            imInfo.data?[0].friendInfo?.userProfile?.faceUrl, Constants.defaultAvatar);
        eventBus.notify(setStateEvent);

        TUICallKitPlatform.instance.updateCallStateToNative();
      },
      onUserLeave: (String userId) async {
        debugPrint("----------onUserLeave: userId -> $userId----------");
        for (var remoteUser in CallState.instance.remoteUserList) {
          if (remoteUser.id == userId) {
            CallState.instance.remoteUserList.remove(remoteUser);
            eventBus.notify(setStateEvent);
            break;
          }
        }

        if (CallState.instance.remoteUserList.isEmpty) {
          CallState.instance.cleanState();
          eventBus.notify(setStateEventOnCallEnd);
        }

        TUICallKitPlatform.instance.updateCallStateToNative();

        if (TUICallScene.singleCall == CallState.instance.scene) {
          TUIToast.show(content: CallKit_t('对方已挂断，通话结束'));
        } else {
          String? nickName =
              await CallState.instance.nameCallback?.call(userId) ?? userId;
          TUIToast.show(content: '$nickName ${CallKit_t('结束了通话')}');
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
        TUICallKitPlatform.instance.stopRing();
        CallState.instance.cleanState();
        eventBus.notify(setStateEvent);
        TUICallKitPlatform.instance.updateCallStateToNative();
      },
      onUserSigExpired: () {
        debugPrint("----------onUserSigExpired----------");
        CallManager.instance.hangup();
        TUICallKitPlatform.instance.stopRing();
        CallState.instance.cleanState();
        eventBus.notify(setStateEvent);
        TUICallKitPlatform.instance.updateCallStateToNative();
      });

  void init() {
    PreferenceUtils.getInstance()
        .getBool(Constants.spKeyEnableMuteMode, false)
        .then((value) => {enableMuteMode = value});
  }

  void registerEngineObserver() {
    TUICallEngine.instance.addObserver(observer);
  }

  void unRegisterEngineObserver() {
    TUICallEngine.instance.removeObserver(observer);
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
    } else if (calleeIdList.length > 1) {
      CallState.instance.scene = TUICallScene.multiCall;
    } else {
      CallState.instance.scene = TUICallScene.singleCall;
    }
    CallState.instance.mediaType = callMediaType;

    CallState.instance.selfUser.callRole = TUICallRole.called;

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
    }

    final imFriendsUserInfos = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .getFriendsInfo(userIDList: allUserId);
    for (var imFriendUserInfo in imFriendsUserInfos.data!) {
      if (imFriendUserInfo.friendInfo?.userID == CallState.instance.selfUser.id) {
        continue;
      }

      if (imFriendUserInfo.friendInfo?.userID == callerId) {
        CallState.instance.caller.nickname =
            StringStream.makeNull(imFriendUserInfo.friendInfo?.userProfile?.nickName, "");
        CallState.instance.caller.remark =
            StringStream.makeNull(imFriendUserInfo.friendInfo?.friendRemark, "");
        CallState.instance.caller.avatar = StringStream.makeNull(
            imFriendUserInfo.friendInfo?.userProfile?.faceUrl, Constants.defaultAvatar);
        CallState.instance.caller.callStatus = TUICallStatus.waiting;
        CallState.instance.caller.callRole = TUICallRole.caller;
      } else {
        for (var calleeUser in CallState.instance.calleeList) {
          if (calleeUser.id == imFriendUserInfo.friendInfo?.userID) {
            calleeUser.nickname =
                StringStream.makeNull(imFriendUserInfo.friendInfo?.userProfile?.nickName, "");
            calleeUser.remark =
                StringStream.makeNull(imFriendUserInfo.friendInfo?.friendRemark, "");
            calleeUser.avatar = StringStream.makeNull(
                imFriendUserInfo.friendInfo?.userProfile?.faceUrl, Constants.defaultAvatar);
            calleeUser.callStatus = TUICallStatus.waiting;
            calleeUser.callRole = TUICallRole.called;
          }
        }
      }
    }

    CallState.instance.remoteUserList.clear();
    if (CallState.instance.caller.id.isNotEmpty &&
        CallState.instance.selfUser.id != CallState.instance.caller.id) {
      CallState.instance.remoteUserList.add(CallState.instance.caller);
    }
    for (var callee in CallState.instance.calleeList) {
      if (CallState.instance.selfUser.id == callee.id) {
        continue;
      }
      CallState.instance.remoteUserList.add(callee);
    }

    CallManager.instance.initAudioPlayDevice();
    CallingBellFeature.startRing();
    eventBus.notify(setStateEventOnCallReceived);
    TUICallKitPlatform.instance.updateCallStateToNative();
  }

  void startTimer() {
    CallState.instance.timeCount = 0;
    CallState.instance._timer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (TUICallStatus.accept != CallState.instance.selfUser.callStatus) {
        stopTimer();
        return;
      }
      CallState.instance.timeCount++;
      eventBus.notify(setStateEventRefreshTiming);
    });
  }

  void stopTimer() {
    CallState.instance._timer.cancel();
  }

  void cleanState() {
    CallState.instance.selfUser.callRole = TUICallRole.none;
    CallState.instance.selfUser.callStatus = TUICallStatus.none;

    CallState.instance.remoteUserList.clear();
    CallState.instance.caller = User();
    CallState.instance.calleeList.clear();
    CallState.instance.calleeIdList.clear();

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
