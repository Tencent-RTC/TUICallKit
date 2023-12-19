import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/data/offline_push_info.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/extensions/calling_bell_feature.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_navigator_observer.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/utils/event_bus.dart';
import 'package:tencent_calls_uikit/src/utils/permission_request.dart';
import 'package:tencent_calls_uikit/src/utils/preference_utils.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class CallManager {
  static final CallManager _instance = CallManager();

  static CallManager get instance => _instance;
  final _im = TencentImSDKPlugin.v2TIMManager;

  CallManager() {
    eventBus.register(setStateEventOnCallReceived, (arg) async {
      if (Platform.isAndroid) {
        final permissionResult = await PermissionRequest.checkCallingPermission(CallState.instance.mediaType);
        if (TUIPermissionResult.granted == permissionResult) {
          TUICallKitNavigatorObserver.getInstance().enterCallingPage();
        } else {
          CallManager.instance.reject();
          TUICallKitPlatform.instance.stopRing();
        }
      } else {
        TUICallKitNavigatorObserver.getInstance().enterCallingPage();
      }
    });
  }

  Future<void> initEngine(int sdkAppID, String userId, String userSig) async {
    CallManager.instance.initResources();
    final result = await TUICallEngine.instance.init(sdkAppID, userId, userSig);

    if (result.code.isEmpty) {
      TUICallEngine.instance.setVideoEncoderParams(
          VideoEncoderParams(resolution: Resolution.resolution_640_360, resolutionMode: ResolutionMode.portrait));
      TUICallEngine.instance
          .setVideoRenderParams(userId, VideoRenderParams(fillMode: FillMode.fill, rotation: Rotation.rotation_0));
      TUICallEngine.instance.setBeautyLevel(6.0);
      _updateLocalSelfUser(userId);
    } else {
      TUIToast.show(content: 'Init Engine Fail');
    }
  }

  Future<TUIResult> call(String userId, TUICallMediaType callMediaType, [TUICallParams? params]) async {
    if (userId.isEmpty) {
      debugPrint("Call failed, userId is empty");
      return TUIResult(code: "-1", message: "Call failed, userId is empty");
    }
    if (TUICallMediaType.none == callMediaType) {
      debugPrint("Call failed, callMediaType is Unknown");
      return TUIResult(code: "-1", message: "Call failed, callMediaType is Unknown");
    }
    if (params != null && params.roomId != null && params.roomId!.intRoomId > Constants.roomIdMaxValue) {
      return TUIResult(
          code: "-1",
          message: "Call failed, roomId.intRoomId Max Value is "
              "2147483647");
    }
    if (params == null) {
      params = TUICallParams();
      params.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo();
    }
    if (Platform.isAndroid) {
      final permissionResult = await PermissionRequest.checkCallingPermission(callMediaType);
      if (TUIPermissionResult.granted == permissionResult) {
        final callResult = await TUICallEngine.instance.call(userId, callMediaType, params);
        if (callResult.code.isEmpty) {
          User user = User();
          user.id = userId;
          user.callRole = TUICallRole.called;
          user.callStatus = TUICallStatus.waiting;
          final imUserInfo = await _im.getFriendshipManager().getFriendsInfo(userIDList: [userId]);
          user.nickname =
              StringStream.makeNull(imUserInfo.data?[0].friendInfo?.userProfile?.nickName, '');
          user.avatar = StringStream.makeNull(
              imUserInfo.data?[0].friendInfo?.userProfile?.faceUrl, Constants.defaultAvatar);
          user.remark = StringStream.makeNull(imUserInfo.data?[0].friendInfo?.friendRemark, '');

          CallState.instance.remoteUserList.add(user);
          CallState.instance.mediaType = callMediaType;
          CallState.instance.scene = TUICallScene.singleCall;
          CallState.instance.selfUser.callRole = TUICallRole.caller;
          CallState.instance.selfUser.callStatus = TUICallStatus.waiting;

          TUICallKitPlatform.instance.updateCallStateToNative();
          initAudioPlayDevice();
          CallingBellFeature.startRing();
          TUICallKitNavigatorObserver.getInstance().enterCallingPage();
          return callResult;
        } else {
          return TUIResult(code: "-1", message: "Call Fail, engine call fail");
        }
      } else {
        return TUIResult(code: "-1", message: "Permission result fail");
      }
    } else {
      final callResult = await TUICallEngine.instance.call(userId, callMediaType, params);
      if (callResult.code.isEmpty) {
        User user = User();
        user.id = userId;
        user.callRole = TUICallRole.called;
        user.callStatus = TUICallStatus.waiting;
        final imUserInfo = await _im.getFriendshipManager().getFriendsInfo(userIDList: [userId]);
        user.nickname =
            StringStream.makeNull(imUserInfo.data?[0].friendInfo?.userProfile?.nickName, '');
        user.avatar = StringStream.makeNull(
            imUserInfo.data?[0].friendInfo?.userProfile?.faceUrl, Constants.defaultAvatar);
        user.remark = StringStream.makeNull(imUserInfo.data?[0].friendInfo?.friendRemark, '');
        CallState.instance.remoteUserList.add(user);
        CallState.instance.mediaType = callMediaType;
        CallState.instance.scene = TUICallScene.singleCall;
        CallState.instance.selfUser.callRole = TUICallRole.caller;
        CallState.instance.selfUser.callStatus = TUICallStatus.waiting;

        TUICallKitPlatform.instance.updateCallStateToNative();
        initAudioPlayDevice();
        CallingBellFeature.startRing();
        TUICallKitNavigatorObserver.getInstance().enterCallingPage();
        return callResult;
      } else {
        return TUIResult(code: "-1", message: "Call Fail, engine call fail");
      }
    }
  }

  Future<TUIResult> groupCall(String groupId, List<String> userIdList, TUICallMediaType mediaType,
      [TUICallParams? params]) async {
    if (groupId.isEmpty) {
      debugPrint("groupCall failed, groupId is empty");
      return TUIResult(code: "-1", message: "groupCall failed, groupId is empty");
    }
    if (TUICallMediaType.none == mediaType) {
      debugPrint("groupCall failed, callMediaType is Unknown");
      return TUIResult(code: "-1", message: "groupCall failed, callMediaType is Unknown");
    }
    if (userIdList.isEmpty) {
      debugPrint("groupCall failed, userIdList is empty");
      return TUIResult(
          code: "-1",
          message: "groupCall failed, userIdList is "
              "empty");
    }
    if (params != null && params.roomId != null && params.roomId!.intRoomId > Constants.roomIdMaxValue) {
      return TUIResult(
          code: "-1",
          message: "Call failed, roomId.intRoomId Max Value is "
              "2147483647");
    }
    if (userIdList.length >= Constants.groupCallMaxUserCount) {
      TUIToast.show(content: "groupCall failed, exceeding max user number: 9");
      return TUIResult(code: "-1", message: "groupCall failed, exceeding max user number: 9");
    }
    if (params == null) {
      params = TUICallParams();
      params.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo();
    }
    if (Platform.isAndroid) {
      final permissionResult = await PermissionRequest.checkCallingPermission(mediaType);
      if (TUIPermissionResult.granted == permissionResult) {
        final callResult = await TUICallEngine.instance.groupCall(groupId, userIdList, mediaType, params);
        if (callResult.code.isEmpty) {
          for (String userId in userIdList) {
            if (userId.isNotEmpty) {
              User user = User();
              user.id = userId;
              user.callRole = TUICallRole.called;
              user.callStatus = TUICallStatus.waiting;
              final imUserInfo =
                  await _im.getFriendshipManager().getFriendsInfo(userIDList: [userId]);
              user.nickname =
                  StringStream.makeNull(imUserInfo.data?[0].friendInfo?.userProfile?.nickName, '');
              user.avatar = StringStream.makeNull(
                  imUserInfo.data?[0].friendInfo?.userProfile?.faceUrl, Constants.defaultAvatar);
              user.remark = StringStream.makeNull(imUserInfo.data?[0].friendInfo?.friendRemark, '');
              CallState.instance.remoteUserList.add(user);
              CallState.instance.calleeList.add(user);
            }
          }

          CallState.instance.mediaType = mediaType;
          CallState.instance.scene = TUICallScene.groupCall;
          CallState.instance.groupId = groupId;

          CallState.instance.selfUser.callRole = TUICallRole.caller;
          CallState.instance.selfUser.callStatus = TUICallStatus.waiting;
          CallState.instance.caller = CallState.instance.selfUser;

          TUICallKitPlatform.instance.updateCallStateToNative();
          initAudioPlayDevice();
          CallingBellFeature.startRing();
          TUICallKitNavigatorObserver.getInstance().enterCallingPage();
          return callResult;
        } else {
          return TUIResult(code: "-1", message: "Call Fail, engine call fail");
        }
      } else {
        return TUIResult(code: "-1", message: "Permission result fail");
      }
    } else {
      final callResult = await TUICallEngine.instance.groupCall(groupId, userIdList, mediaType, params);
      if (callResult.code.isEmpty) {
        for (String userId in userIdList) {
          if (userId.isNotEmpty) {
            User user = User();
            user.id = userId;
            user.callRole = TUICallRole.called;
            user.callStatus = TUICallStatus.waiting;
            final imUserInfo =
                await _im.getFriendshipManager().getFriendsInfo(userIDList: [userId]);
            user.nickname =
                StringStream.makeNull(imUserInfo.data?[0].friendInfo?.userProfile?.nickName, '');
            user.avatar = StringStream.makeNull(
                imUserInfo.data?[0].friendInfo?.userProfile?.faceUrl, Constants.defaultAvatar);
            user.remark = StringStream.makeNull(imUserInfo.data?[0].friendInfo?.friendRemark, '');
            CallState.instance.remoteUserList.add(user);
          }
        }

        CallState.instance.mediaType = mediaType;
        CallState.instance.scene = TUICallScene.groupCall;
        CallState.instance.groupId = groupId;

        CallState.instance.selfUser.callRole = TUICallRole.caller;
        CallState.instance.selfUser.callStatus = TUICallStatus.waiting;

        TUICallKitPlatform.instance.updateCallStateToNative();
        initAudioPlayDevice();
        CallingBellFeature.startRing();
        TUICallKitNavigatorObserver.getInstance().enterCallingPage();
        return callResult;
      } else {
        return TUIResult(code: "-1", message: "Call Fail, engine call fail");
      }
    }
  }

  Future<void> joinInGroupCall(TUIRoomId roomId, String groupId, TUICallMediaType mediaType) async {
    if (roomId.intRoomId <= 0 || roomId.intRoomId >= Constants.roomIdMaxValue) {
      debugPrint("joinInGroupCall failed, roomId is invalid");
      return;
    }
    if (groupId.isEmpty) {
      debugPrint("joinInGroupCall failed, groupId is empty");
      return;
    }
    if (TUICallMediaType.none == mediaType) {
      debugPrint("joinInGroupCall failed, mediaType is unknown");
      return;
    }
    if (Platform.isAndroid) {
      final permissionResult = await PermissionRequest.checkCallingPermission(mediaType);
      if (TUIPermissionResult.granted == permissionResult) {
        final result = await TUICallEngine.instance.joinInGroupCall(roomId, groupId, mediaType);
        if (result.code.isEmpty) {
          CallState.instance.groupId = groupId;
          CallState.instance.roomId = roomId;
          CallState.instance.mediaType = mediaType;
          CallState.instance.scene = TUICallScene.groupCall;
          CallState.instance.selfUser.callRole = TUICallRole.called;
          CallState.instance.selfUser.callStatus = TUICallStatus.accept;

          TUICallKitPlatform.instance.updateCallStateToNative();
          _instance.initAudioPlayDevice();
          TUICallKitNavigatorObserver.getInstance().enterCallingPage();
          return;
        } else {
          TUIToast.show(
              content: "joinInGroupCall Fail, engine call "
                  "fail");
          return;
        }
      } else {
        TUIToast.show(content: "Permission result fail");
        return;
      }
    } else {
      final result = await TUICallEngine.instance.joinInGroupCall(roomId, groupId, mediaType);
      if (result.code.isEmpty) {
        CallState.instance.groupId = groupId;
        CallState.instance.roomId = roomId;
        CallState.instance.mediaType = mediaType;
        CallState.instance.scene = TUICallScene.groupCall;
        CallState.instance.selfUser.callRole = TUICallRole.called;
        CallState.instance.selfUser.callStatus = TUICallStatus.accept;
        TUICallKitPlatform.instance.updateCallStateToNative();
        _instance.initAudioPlayDevice();
        TUICallKitNavigatorObserver.getInstance().enterCallingPage();
        return;
      } else {
        TUIToast.show(content: "joinInGroupCall Fail,engine call fail");
        return;
      }
    }
  }

  Future<TUIResult> accept() async {
    final result = await TUICallEngine.instance.accept();
    if (result.code.isEmpty) {
      CallState.instance.selfUser.callStatus = TUICallStatus.accept;
    } else {
      CallState.instance.selfUser.callStatus = TUICallStatus.none;
    }

    TUICallKitPlatform.instance.updateCallStateToNative();

    return result;
  }

  Future<TUIResult> reject() async {
    final result = await TUICallEngine.instance.reject();
    CallState.instance.selfUser.callStatus = TUICallStatus.none;

    TUICallKitPlatform.instance.updateCallStateToNative();

    return result;
  }

  Future<void> switchCallMediaType(TUICallMediaType mediaType) async {
    TUICallEngine.instance.switchCallMediaType(mediaType);

    TUICallKitPlatform.instance.updateCallStateToNative();
  }

  Future<TUIResult> hangup() async {
    final result = await TUICallEngine.instance.hangup();
    CallState.instance.selfUser.callStatus = TUICallStatus.none;

    TUICallKitPlatform.instance.updateCallStateToNative();

    return result;
  }

  Future<TUIResult> openCamera(TUICamera camera, int viewId) async {
    final result = await TUICallEngine.instance.openCamera(camera, viewId);
    if (result.code.isEmpty && TUICallStatus.none != CallState.instance.selfUser.callStatus) {
      CallState.instance.isCameraOpen = true;
      CallState.instance.camera = camera;
      CallState.instance.selfUser.videoAvailable = true;
    }

    TUICallKitPlatform.instance.updateCallStateToNative();

    return result;
  }

  Future<void> closeCamera() async {
    TUICallEngine.instance.closeCamera();
    CallState.instance.isCameraOpen = false;
    CallState.instance.selfUser.videoAvailable = false;

    TUICallKitPlatform.instance.updateCallStateToNative();
  }

  Future<void> switchCamera(TUICamera camera) async {
    TUICallEngine.instance.switchCamera(camera);
    CallState.instance.camera = camera;

    TUICallKitPlatform.instance.updateCallStateToNative();
  }

  Future<TUIResult> openMicrophone() async {
    final result = await TUICallEngine.instance.openMicrophone();
    CallState.instance.isMicrophoneMute = false;

    TUICallKitPlatform.instance.updateCallStateToNative();

    if (Platform.isIOS && result.code.isEmpty) {
      TUICallKitPlatform.instance.openMicrophone();
    }
    return result;
  }

  Future<void> closeMicrophone() async {
    TUICallEngine.instance.closeMicrophone();
    CallState.instance.isMicrophoneMute = true;

    TUICallKitPlatform.instance.updateCallStateToNative();

    if (Platform.isIOS) {
      TUICallKitPlatform.instance.closeMicrophone();
    }
  }

  Future<void> selectAudioPlaybackDevice(TUIAudioPlaybackDevice device) async {
    TUICallEngine.instance.selectAudioPlaybackDevice(device);
    CallState.instance.audioDevice = device;

    TUICallKitPlatform.instance.updateCallStateToNative();
  }

  Future<void> startRemoteView(String userId, int viewId) async {
    await TUICallEngine.instance.startRemoteView(userId, viewId);

    TUICallKitPlatform.instance.updateCallStateToNative();
  }

  Future<void> stopRemoteView(String userId) async {
    await TUICallEngine.instance.stopRemoteView(userId);

    TUICallKitPlatform.instance.updateCallStateToNative();
  }

  Future<TUIResult> setSelfInfo(String nickname, String avatar) async {
    final result = await TUICallEngine.instance.setSelfInfo(nickname, avatar);
    return result;
  }

  Future<void> inviteUser(List<String> userIdList) async {
    TUICallParams params = TUICallParams();
    params.offlinePushInfo = OfflinePushInfoConfig.createOfflinePushInfo();
    await TUICallEngine.instance.iniviteUser(
        userIdList,
        params,
        TUIValueCallback(
            onSuccess: (userIds) async {
              if (userIds != null && userIds is List && userIds.isNotEmpty) {
                List<String> list = [];
                for (Object userId in userIds) {
                  if (userId is String) {
                    list.add(userId);
                  }
                }
                final imUserList =
                    await _im.getFriendshipManager().getFriendsInfo(userIDList: list);
                if (imUserList.data != null) {
                  imUserList.data?.forEach((item) {
                    User user = User();
                    user.id = StringStream.makeNull(item.friendInfo?.userID, '');
                    user.nickname =
                        StringStream.makeNull(item.friendInfo?.userProfile?.nickName, '');
                    user.avatar = StringStream.makeNull(
                        item.friendInfo?.userProfile?.faceUrl, Constants.defaultAvatar);
                    user.remark = StringStream.makeNull(item.friendInfo?.friendRemark, '');
                    user.callStatus = TUICallStatus.waiting;
                    CallState.instance.remoteUserList.add(user);
                  });
                  eventBus.notify(setStateEvent);
                }
              }
            },
            onError: (code, message) {}));
  }

  Future<TUIResult> login(int sdkAppId, String userId, String userSig) async {
    await CallState.instance.registerEngineObserver();
    TUIResult result = TUIResult(code: '', message: 'success');
    await TUILogin.instance.login(
        sdkAppId,
        userId,
        userSig,
        TUICallback(
            onSuccess: () {},
            onError: (code, message) {
              result = TUIResult(code: "$code", message: message);
            }));
    return result;
  }

  Future<void> logout() async {
    await TUILogin.instance.logout(TUICallback(onSuccess: () {}, onError: (code, message) {}));
  }

  Future<void> setCallingBell(String assetName) async {
    String filePath = await CallingBellFeature.getAssetsFilePath(assetName);
    PreferenceUtils.getInstance().saveString(CallingBellFeature.keyRingPath, filePath);
  }

  Future<void> enableFloatWindow(bool enable) async {
    CallState.instance.enableFloatWindow = enable;
  }

  Future<void> enableMuteMode(bool enable) async {
    CallState.instance.enableMuteMode = enable;
    PreferenceUtils.getInstance().saveBool(Constants.spKeyEnableMuteMode, CallState.instance.enableMuteMode);
  }

  void initAudioPlayDevice() {
    if (TUICallMediaType.audio == CallState.instance.mediaType && TUICallScene.singleCall == CallState.instance.scene) {
      CallState.instance.audioDevice = TUIAudioPlaybackDevice.earpiece;
    } else {
      CallState.instance.audioDevice = TUIAudioPlaybackDevice.speakerphone;
    }
    CallManager.instance.selectAudioPlaybackDevice(CallState.instance.audioDevice);
  }

  void handleLoginSuccess(int sdkAppId, String userId, String userSig) async {
    await CallState.instance.registerEngineObserver();
    await CallManager.instance.initEngine(sdkAppId, userId, userSig);
    _instance._adaptiveComponentReport();
  }

  void handleLogoutSuccess() {
    TUICallEngine.instance.unInit();
    CallState.instance.unRegisterEngineObserver();
    TUICallKitPlatform.instance.stopRing();
    CallState.instance.cleanState();
    TUICallKitPlatform.instance.updateCallStateToNative();
  }

  Future<void> initResources() async {
    var resources = {};
    resources["k_0000088"] = CallKit_t("等待接听");
    resources["k_0000089"] = CallKit_t("请同时打开后台弹出界面和显示悬浮窗权限");
    TUICallKitPlatform.instance.initResources(resources);
  }

  void handleAppEnterForeground() {
    if (Platform.isIOS &&
        CallState.instance.selfUser.callStatus != TUICallStatus.none &&
        TUICallKitNavigatorObserver.currentPage == CallPage.none) {
      CallState.instance.handleCallReceived(CallState.instance.caller.id,
          CallState.instance.calleeIdList, CallState.instance.groupId, CallState.instance.mediaType);
    }
  }

  void _adaptiveComponentReport() async {
    await TUICallEngine.instance.callExperimentalAPI({
      "api": "setFramework",
      "params": {
        "framework": 7,
        "component": 14,
        "language": 9,
      }
    });
  }

  void _updateLocalSelfUser(String userId) async {
    CallState.instance.selfUser.id = userId;
    final imInfo = await _im.getUsersInfo(userIDList: [userId]);
    CallState.instance.selfUser.nickname = StringStream.makeNull(imInfo.data?[0].nickName, '');
    CallState.instance.selfUser.avatar =
        StringStream.makeNull(imInfo.data?[0].faceUrl, Constants.defaultAvatar);
  }
}
