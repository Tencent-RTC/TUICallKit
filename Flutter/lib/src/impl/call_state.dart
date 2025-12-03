import 'dart:async';
import 'dart:io';

import 'package:tencent_calls_uikit/src/call_engine.dart';
import 'package:tencent_calls_uikit/src/call_define.dart';
import 'package:tencent_calls_uikit/src/call_observer.dart';
import 'package:tencent_calls_uikit/src/impl/call_manager.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/extensions/calling_bell_feature.dart';
import 'package:tencent_calls_uikit/src/extensions/trtc_logger.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/platform/call_engine_platform_interface.dart';
import 'package:tencent_calls_uikit/src/platform/call_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/utils/preference.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

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
  bool showVirtualBackgroundButton = false;
  bool enableBlurBackground = false;
  NetworkQualityHint networkQualityReminder = NetworkQualityHint.none;

  bool isChangedBigSmallVideo = false;
  bool isOpenFloatWindow = false;
  bool enableIncomingBanner = false;
  bool isInNativeIncomingBanner = false;

  bool isStartForegroundService = false;
  bool forceUseV2API = false;

  final TUICallObserver observer = TUICallObserver(
      onError: (int code, String message) {
        TRTCLogger.info('TUICallObserver onError(code:$code, message:$message)');
      },
      onCallReceived: (String callId, String callerId, List<String> calleeIdList, TUICallMediaType mediaType, CallObserverExtraInfo info) async {
        TRTCLogger.info(
            'TUICallObserver onCallReceived(callId:$callId callerId:$callerId, calleeIdList:$calleeIdList, callMediaType:$mediaType, info:${info.toString()}), version:${Constants.pluginVersion}');
        await CallState.instance
            .handleCallReceivedData(callerId, calleeIdList, info.chatGroupId, mediaType);
        await TUICallKitPlatform.instance.updateCallStateToNative();
        await CallManager.instance.enableWakeLock(true);
        CallingBellFeature.startRing();

        if (Platform.isIOS) {
          if (CallState.instance.enableIncomingBanner) {
            CallState.instance.isInNativeIncomingBanner = true;
            await TUICallKitPlatform.instance.showIncomingBanner();
          } else {
            CallState.instance.isInNativeIncomingBanner = false;
            CallManager.instance.launchCallingPage();
          }
        } else if (Platform.isAndroid) {
          if (await CallManager.instance.isScreenLocked()) {
            CallManager.instance.openLockScreenApp();
            return;
          }

          if (CallState.instance.enableIncomingBanner && !(await CallManager.instance.isSamsungDevice())) {
            CallState.instance.isInNativeIncomingBanner = true;
            CallManager.instance.showIncomingBanner();
          } else {
            if (await TUICallKitPlatform.instance.isAppInForeground()) {
              CallState.instance.isInNativeIncomingBanner = false;
              CallManager.instance.launchCallingPage();
            } else {
              CallManager.instance.pullBackgroundApp();
            }
          }
        }
      },
      onCallNotConnected: (String callId, TUICallMediaType mediaType, CallEndReason reason,
          String userId, CallObserverExtraInfo info) {
        TRTCLogger.info(
            'TUICallObserver onCallNotConnected(callId:$callId, mediaType:$mediaType, reason:$reason, userId:$userId, info:${info.toString()})');
        CallingBellFeature.stopRing();
        if (CallState.instance.mediaType == TUICallMediaType.video && CallState.instance.isCameraOpen ) {
          CallManager.instance.closeCamera();
        }
        CallState.instance.cleanState();
        TUICore.instance.notifyEvent(setStateEventOnCallEnd);
        TUICallKitPlatform.instance.updateCallStateToNative();
        CallManager.instance.enableWakeLock(false);
      },
      onCallBegin: (String callId, TUICallMediaType mediaType, CallObserverExtraInfo info) {
        TRTCLogger.info(
            'TUICallObserver onCallBegin(callId:$callId, mediaType:$mediaType, info:${info.toString()})');
        CallState.instance.startTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        CallingBellFeature.stopRing();
        CallState.instance.roomId = info.roomId;
        CallState.instance.mediaType = mediaType;
        CallState.instance.selfUser.callRole = info.role;
        CallState.instance.selfUser.callStatus = TUICallStatus.accept;
        if (CallState.instance.isMicrophoneMute) {
          CallManager.instance.closeMicrophone();
        } else {
          CallManager.instance.openMicrophone();
        }
        CallManager.instance.selectAudioPlaybackDevice(CallState.instance.audioDevice);
        CallState.instance.startTimer();
        CallState.instance.isChangedBigSmallVideo = true;
        CallState.instance.isInNativeIncomingBanner = false;
        TUICore.instance.notifyEvent(setStateEvent);
        TUICore.instance.notifyEvent(setStateEventOnCallBegin);
        TUICallKitPlatform.instance.updateCallStateToNative();
      },
      onCallEnd: (String callId, TUICallMediaType mediaType, CallEndReason reason,
          String userId, double totalTime, CallObserverExtraInfo info) {
        TRTCLogger.info(
            'TUICallObserver onCallEnd(callId:$callId, mediaType:$mediaType, reason:$reason, userId:$userId totalTime:$totalTime, info:${info.toString()})');
        CallState.instance.stopTimer();
        if (CallState.instance.mediaType == TUICallMediaType.video && CallState.instance.isCameraOpen ) {
          CallManager.instance.closeCamera();
        }
        CallState.instance.cleanState();
        TUICore.instance.notifyEvent(setStateEventOnCallEnd);
        TUICallKitPlatform.instance.updateCallStateToNative();
        CallManager.instance.enableWakeLock(false);
      },
      onCallMediaTypeChanged:
          (TUICallMediaType oldCallMediaType, TUICallMediaType newCallMediaType) {
        CallState.instance.mediaType = newCallMediaType;
        TUICore.instance.notifyEvent(setStateEvent);
        TUICallKitPlatform.instance.updateCallStateToNative();
      },
      onUserReject: (String userId) {
        TRTCLogger.info('TUICallObserver onUserReject(userId:$userId)');
        for (var remoteUser in CallState.instance.remoteUserList) {
          if (remoteUser.id == userId) {
            CallState.instance.remoteUserList.remove(remoteUser);
            TUICore.instance.notifyEvent(setStateEvent);
            break;
          }
        }

        if (CallState.instance.remoteUserList.isEmpty) {
          CallingBellFeature.stopRing();
          CallState.instance.cleanState();
          TUICore.instance.notifyEvent(setStateEventOnCallEnd);
        }
        TUICallKitPlatform.instance.updateCallStateToNative();
        if (TUICallScene.singleCall == CallState.instance.scene) {
          CallManager.instance.showToast(CallKit_t('otherPartyDeclinedCallRequest'));
        }
      },
      onUserNoResponse: (String userId) {
        TRTCLogger.info('TUICallObserver onUserNoResponse(userId:$userId)');
        for (var remoteUser in CallState.instance.remoteUserList) {
          if (remoteUser.id == userId) {
            CallState.instance.remoteUserList.remove(remoteUser);
            TUICore.instance.notifyEvent(setStateEvent);
            break;
          }
        }

        if (CallState.instance.remoteUserList.isEmpty) {
          CallingBellFeature.stopRing();
          CallState.instance.cleanState();
          TUICore.instance.notifyEvent(setStateEventOnCallEnd);
        }

        TUICallKitPlatform.instance.updateCallStateToNative();
        if (TUICallScene.singleCall == CallState.instance.scene) {
          CallManager.instance.showToast(CallKit_t('otherPartyNoResponse'));
        }
      },
      onUserLineBusy: (String userId) {
        Timer.periodic(const Duration(milliseconds: 200), (timer) {
          TRTCLogger.info('TUICallObserver onUserLineBusy(userId:$userId)');
          for (var remoteUser in CallState.instance.remoteUserList) {
            if (remoteUser.id == userId) {
              CallState.instance.remoteUserList.remove(remoteUser);
              TUICore.instance.notifyEvent(setStateEvent);
              break;
            }
          }

          if (CallState.instance.remoteUserList.isEmpty) {
            CallingBellFeature.stopRing();
            CallState.instance.cleanState();

            TUICore.instance.notifyEvent(setStateEventOnCallEnd);
          }

          TUICallKitPlatform.instance.updateCallStateToNative();

          if (TUICallScene.singleCall == CallState.instance.scene) {
            CallManager.instance.showToast(CallKit_t('otherPartyBusy'));
          } else {
            CallManager.instance.showToast('$userId ${CallKit_t('busy')}');
          }
          timer.cancel();
        });
      },
      onUserJoin: (String userId) async {
        TRTCLogger.info('TUICallObserver onUserJoin(userId:$userId)');
        for (var remoteUser in CallState.instance.remoteUserList) {
          if (remoteUser.id == userId) {
            remoteUser.callStatus = TUICallStatus.accept;
            TUICore.instance.notifyEvent(setStateEvent);

            TUICallKitPlatform.instance.updateCallStateToNative();
            return;
          }
        }
        
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
        TUICore.instance.notifyEvent(setStateEvent);

        TUICallKitPlatform.instance.updateCallStateToNative();
      },
      onUserLeave: (String userId) {
        TRTCLogger.info('TUICallObserver onUserLeave(userId:$userId)');
        for (var remoteUser in CallState.instance.remoteUserList) {
          if (remoteUser.id == userId) {
            CallState.instance.remoteUserList.remove(remoteUser);
            TUICore.instance.notifyEvent(setStateEvent);
            break;
          }
        }

        if (CallState.instance.remoteUserList.isEmpty) {
          CallState.instance.cleanState();
          TUICore.instance.notifyEvent(setStateEventOnCallEnd);
        }

        TUICallKitPlatform.instance.updateCallStateToNative();

        if (TUICallScene.singleCall == CallState.instance.scene) {
          CallManager.instance.showToast(CallKit_t('otherPartyHungUp'));
        }
      },
      onUserVideoAvailable: (String userId, bool isVideoAvailable) {
        TRTCLogger.info(
            'TUICallObserver onUserVideoAvailable(userId:$userId, isVideoAvailable:$isVideoAvailable)');
        for (var remoteUser in CallState.instance.remoteUserList) {
          if (remoteUser.id == userId) {
            remoteUser.videoAvailable = isVideoAvailable;
            TUICore.instance.notifyEvent(setStateEvent);

            TUICallKitPlatform.instance.updateCallStateToNative();
            return;
          }
        }
      },
      onUserAudioAvailable: (String userId, bool isAudioAvailable) {
        TRTCLogger.info(
            'TUICallObserver onUserAudioAvailable(userId:$userId, isVideoAvailable:$isAudioAvailable)');
        for (var remoteUser in CallState.instance.remoteUserList) {
          if (remoteUser.id == userId) {
            remoteUser.audioAvailable = isAudioAvailable;
            TUICore.instance.notifyEvent(setStateEvent);
            return;
          }
        }
      },
      onUserNetworkQualityChanged: (List<TUINetworkQualityInfo> networkQualityList) {
        if (networkQualityList.isEmpty) {
          return;
        }
        if(TUICallScene.groupCall == CallState.instance.scene) {
          for (var networkQualityInfo in networkQualityList) {
            if (networkQualityInfo.userId == CallState.instance.selfUser.id) {
              CallState.instance.selfUser.networkQualityReminder = CallState.instance.isBadNetwork(networkQualityInfo.quality);
              continue;
            }
            for (var remoteUser in CallState.instance.remoteUserList) {
              if (remoteUser.id == networkQualityInfo.userId) {
                remoteUser.networkQualityReminder = CallState.instance.isBadNetwork(networkQualityInfo.quality);
              }
            }
          }
        } else if (TUICallScene.singleCall == CallState.instance.scene) {
          TUINetworkQuality localQuality = TUINetworkQuality.unknown;
          TUINetworkQuality remoteQuality = TUINetworkQuality.unknown;

          for (var networkQualityInfo in networkQualityList) {
            if (CallState.instance.selfUser.id == networkQualityInfo.userId) {
              localQuality = networkQualityInfo.quality;
            } else {
              remoteQuality = networkQualityInfo.quality;
            }
          }

          if (CallState.instance.isBadNetwork(localQuality)) {
            CallState.instance.networkQualityReminder = NetworkQualityHint.local;
          } else if (CallState.instance.isBadNetwork(remoteQuality)) {
            CallState.instance.networkQualityReminder = NetworkQualityHint.remote;
          } else {
            CallState.instance.networkQualityReminder = NetworkQualityHint.none;
          }
        }
        TUICore.instance.notifyEvent(setStateEvent);
      },
      onUserVoiceVolumeChanged: (Map<String, int> volumeMap) {
        bool needUpdate2Native = false;
        for (var remoteUser in CallState.instance.remoteUserList) {
          var volume = volumeMap[remoteUser.id] ?? 0;
          remoteUser.playOutVolume = volume;
          if (volume > 10) {
            needUpdate2Native = true;
          }
        }

        var selfVolume =  volumeMap[CallState.instance.selfUser.id] ?? 0;
        CallState.instance.selfUser.playOutVolume = selfVolume;
        if (selfVolume > 10) {
          needUpdate2Native = true;
        }

        if (needUpdate2Native) {
          TUICallKitPlatform.instance.updateCallStateToNative();
          TUICore.instance.notifyEvent(setStateEvent);
        }
      },
      onKickedOffline: () {
        TRTCLogger.info('TUICallObserver onKickedOffline()');
        CallManager.instance.hangup();
        CallingBellFeature.stopRing();
        CallState.instance.cleanState();
        TUICore.instance.notifyEvent(setStateEvent);
        TUICallKitPlatform.instance.updateCallStateToNative();
      },
      onUserSigExpired: () {
        TRTCLogger.info('TUICallObserver onUserSigExpired()');
        CallManager.instance.hangup();
        CallingBellFeature.stopRing();
        CallState.instance.cleanState();
        TUICore.instance.notifyEvent(setStateEvent);
        TUICallKitPlatform.instance.updateCallStateToNative();
      });

  void init() {
    PreferenceUtils.getInstance()
        .getBool(Constants.spKeyEnableMuteMode, false)
        .then((value) => {enableMuteMode = value});
  }

  Future<void> registerEngineObserver() async {
    TRTCLogger.info('CallState registerEngineObserver');
    await TUICallEngine.instance.addObserver(observer);
  }

  void unRegisterEngineObserver() {
    TUICallEnginePlatform.instance.removeAllObserver();
  }

  Future<void> handleCallReceivedData(String callerId, List<String> calleeIdList, String groupId,
      TUICallMediaType callMediaType) async {
    CallState.instance.caller.id = callerId;
    CallState.instance.calleeIdList.clear();
    CallState.instance.calleeIdList.addAll(calleeIdList);
    CallState.instance.groupId = groupId;
    CallState.instance.mediaType = callMediaType;
    CallState.instance.selfUser.callStatus = TUICallStatus.waiting;

    if (callMediaType == TUICallMediaType.none || calleeIdList.isEmpty) {
      return;
    }

    if (calleeIdList.length >= Constants.groupCallMaxUserCount) {
      CallManager.instance.showToast(CallKit_t('exceededMaximumNumber'));
      return;
    }

    CallState.instance.groupId = groupId;
    if (CallState.instance.groupId.isNotEmpty || calleeIdList.length > 1) {
      CallState.instance.scene = TUICallScene.groupCall;
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
  }

  void startTimer() {
    CallState.instance.timeCount = 0;
    CallState.instance._timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (TUICallStatus.accept != CallState.instance.selfUser.callStatus) {
        stopTimer();
        return;
      }
      CallState.instance.timeCount++;
      TUICore.instance.notifyEvent(setStateEventRefreshTiming);
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
    CallState.instance.enableBlurBackground = false;
  }

  bool isBadNetwork(TUINetworkQuality quality)  {
    return quality == TUINetworkQuality.bad || quality == TUINetworkQuality.vBad || quality == TUINetworkQuality.down;
  }
}
