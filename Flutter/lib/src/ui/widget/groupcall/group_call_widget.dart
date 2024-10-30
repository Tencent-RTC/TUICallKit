import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_navigator_observer.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/extent_button.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/timing_widget.dart';
import 'package:tencent_calls_uikit/src/ui/widget/groupcall/group_call_user_widget_data.dart';
import 'package:tencent_calls_uikit/src/utils/permission.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

import 'group_call_user_widget.dart';

class GroupCallWidget extends StatefulWidget {
  final Function close;

  const GroupCallWidget({
    Key? key,
    required this.close,
  }) : super(key: key);

  @override
  State<GroupCallWidget> createState() => _GroupCallWidgetState();
}

class _GroupCallWidgetState extends State<GroupCallWidget> {
  ITUINotificationCallback? setSateCallBack;
  ITUINotificationCallback? groupCallUserWidgetRefreshCallback;
  bool isFunctionExpand = true;
  late final List<GroupCallUserWidget> _userViewWidgets = [];

  _initUsersViewWidget() {
    GroupCallUserWidgetData.initBlockCounter();
    GroupCallUserWidgetData.updateBlockBigger(CallState.instance.remoteUserList.length + 1);
    GroupCallUserWidgetData.initCanPlaceSquare(
        GroupCallUserWidgetData.blockBigger, CallState.instance.remoteUserList.length + 1);
    _userViewWidgets.clear();

    GroupCallUserWidgetData.blockCount++;
    _userViewWidgets.add(GroupCallUserWidget(
        index: GroupCallUserWidgetData.blockCount, user: CallState.instance.selfUser));

    for (var remoteUser in CallState.instance.remoteUserList) {
      GroupCallUserWidgetData.blockCount++;
      _userViewWidgets
          .add(GroupCallUserWidget(index: GroupCallUserWidgetData.blockCount, user: remoteUser));
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    setSateCallBack = (arg) {
      if (mounted) {
        setState(() {
          _initUsersViewWidget();
        });
      }
    };

    groupCallUserWidgetRefreshCallback = (arg) {
      if (mounted) {
        if (GroupCallUserWidgetData.hasBiggerSquare()) {
          isFunctionExpand = false;
        } else {
          isFunctionExpand = true;
        }
        setState(() {});
      }
    };

    TUICore.instance.registerEvent(setStateEvent, setSateCallBack);
    TUICore.instance
        .registerEvent(setStateEventGroupCallUserWidgetRefresh, groupCallUserWidgetRefreshCallback);

    GroupCallUserWidgetData.initBlockBigger();
    _initUsersViewWidget();
  }

  @override
  void dispose() {
    super.dispose();
    TUICore.instance.unregisterEvent(setStateEvent, setSateCallBack);
    TUICore.instance.unregisterEvent(
        setStateEventGroupCallUserWidgetRefresh, groupCallUserWidgetRefreshCallback);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          padding: const EdgeInsets.only(top: 40),
          color: const Color.fromRGBO(45, 45, 45, 1.0),
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: <Widget>[
              _buildUserVideoList(),
              _buildTopWidget(),
              _buildFunctionWidget(),
            ],
          ),
        ),
    );
  }

  _buildUserVideoList() {
    return (TUICallStatus.waiting == CallState.instance.selfUser.callStatus &&
            CallState.instance.selfUser.callRole == TUICallRole.called)
        ? _buildReceivedGroupCallWaitting()
        : _buildGroupCallView();
  }

  _buildReceivedGroupCallWaitting() {
    return Positioned(
        top: 0,
        left: 0,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 150),
              height: 120,
              width: 120,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: Image(
                image: NetworkImage(StringStream.makeNull(
                    CallState.instance.caller.avatar, Constants.defaultAvatar)),
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stackTrace) => Image.asset(
                  'assets/images/user_icon.png',
                  package: 'tencent_calls_uikit',
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                User.getUserDisplayName(CallState.instance.caller),
                textScaleFactor: 1.0,
                style: const TextStyle(fontSize: 24, color: Colors.white),
              ),
            ),
            Text(
              CallKit_t("invitedToGroupCall"),
              textScaleFactor: 1.0,
              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(
              height: 50,
            ),
            Text(
              CallKit_t("theyAreAlsoThere"),
              textScaleFactor: 1.0,
              style: const TextStyle(color: Colors.white),
            ),
            Container(
              margin: const EdgeInsets.only(top: 10),
              child: Wrap(
                spacing: 5,
                runSpacing: 5,
                children: List.generate(CallState.instance.calleeList.length, ((index) {
                  return Container(
                    height: 30,
                    width: 30,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                    ),
                    child: Image(
                      image: NetworkImage(StringStream.makeNull(
                          CallState.instance.calleeList[index].avatar, Constants.defaultAvatar)),
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stackTrace) => Image.asset(
                        'assets/images/user_icon.png',
                        package: 'tencent_calls_uikit',
                      ),
                    ),
                  );
                })),
              ),
            )
          ],
        ));
  }

  _buildGroupCallView() {
    return Positioned(
        top: 50,
        left: 0,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width * 4 / 3,
        child: Stack(children: _userViewWidgets));
  }

  _buildTopWidget() {
    final floatWindowBtnWidget = CallState.instance.enableFloatWindow
        ? Visibility(
            visible: CallState.instance.enableFloatWindow,
            child: InkWell(
                onTap: () => _openFloatWindow(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 12, 12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      'assets/images/floating_button.png',
                      package: 'tencent_calls_uikit',
                    ),
                  ),
                )),
          )
        : const SizedBox();

    final timerWidget = (TUICallStatus.accept == CallState.instance.selfUser.callStatus)
        ? const SizedBox(width: 100, child: Center(child: TimingWidget()))
        : const SizedBox();

    final inviteBtnWidget = Visibility(
      visible: TUICallStatus.accept == CallState.instance.selfUser.callStatus ||
          TUICallRole.caller == CallState.instance.selfUser.callRole,
      child: InkWell(
          onTap: () => TUICallKitNavigatorObserver.getInstance().enterInviteUserPage(),
          child: SizedBox(
            width: 24,
            height: 24,
            child: Image.asset(
              'assets/images/add_user.png',
              package: 'tencent_calls_uikit',
            ),
          )),
    );

    return Positioned(
        top: 15,
        width: MediaQuery.of(context).size.width,
        height: 100,
        child: Stack(
          children: [
            Positioned(left: 16, child: floatWindowBtnWidget),
            Positioned(left: (MediaQuery.of(context).size.width / 2) - 50, child: timerWidget),
            Positioned(right: 16, child: inviteBtnWidget),
          ],
        ));
  }

  _buildFunctionWidget() {
    Widget functionWidget;
    if (TUICallStatus.waiting == CallState.instance.selfUser.callStatus &&
        TUICallRole.called == CallState.instance.selfUser.callRole) {
      functionWidget = _buildAudioAndVideoCalleeWaitingFunctionView();
    } else {
      functionWidget = _buildVideoCallerAndCalleeAcceptedFunctionView();
    }

    return Positioned(bottom: 0, width: MediaQuery.of(context).size.width, child: functionWidget);
  }

  _buildAudioAndVideoCalleeWaitingFunctionView() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ExtendButton(
              imgUrl: "assets/images/hangup.png",
              tips: CallKit_t("hangUp"),
              textColor: Colors.white,
              imgHeight: 64,
              onTap: () {
                _handleReject(widget.close);
              },
            ),
            ExtendButton(
              imgUrl: "assets/images/dialing.png",
              tips: CallKit_t("accept"),
              textColor: Colors.white,
              imgHeight: 64,
              onTap: () {
                _handleAccept();
              },
            ),
          ],
        ),
        const SizedBox(height: 80)
      ],
    );
  }

  _buildVideoCallerAndCalleeAcceptedFunctionView() {
    double bigBtnHeight = 52;
    double smallBtnHeight = 35;
    double edge = 40;
    double bottomEdge = 10;
    int duration = 300;
    int btnWidth = 100;
    Curve curve = Curves.easeInOut;
    return ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        child: GestureDetector(
            onVerticalDragUpdate: (details) => _functionWidgetVerticalDragUpdate(details),
            child: AnimatedContainer(
                curve: curve,
                height: isFunctionExpand ? 200 : 90,
                duration: Duration(milliseconds: duration),
                color: const Color.fromRGBO(52, 56, 66, 1.0),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: isFunctionExpand
                          ? ((MediaQuery.of(context).size.width / 4) - (btnWidth / 2))
                          : (MediaQuery.of(context).size.width * 2 / 6 - btnWidth / 2),
                      bottom: isFunctionExpand ? bottomEdge + bigBtnHeight + edge : bottomEdge,
                      child: ExtendButton(
                        imgUrl: CallState.instance.isMicrophoneMute
                            ? "assets/images/mute_on.png"
                            : "assets/images/mute.png",
                        tips: isFunctionExpand
                            ? (CallState.instance.isMicrophoneMute
                                ? CallKit_t("microphoneIsOff")
                                : CallKit_t("microphoneIsOn"))
                            : '',
                        textColor: Colors.white,
                        imgHeight: isFunctionExpand ? bigBtnHeight : smallBtnHeight,
                        onTap: () {
                          _handleSwitchMic();
                        },
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: isFunctionExpand
                          ? (MediaQuery.of(context).size.width / 2 - btnWidth / 2)
                          : (MediaQuery.of(context).size.width * 3 / 6 - btnWidth / 2),
                      bottom: isFunctionExpand ? bottomEdge + bigBtnHeight + edge : bottomEdge,
                      child: ExtendButton(
                        imgUrl:
                            CallState.instance.audioDevice == TUIAudioPlaybackDevice.speakerphone
                                ? "assets/images/handsfree_on.png"
                                : "assets/images/handsfree.png",
                        tips: isFunctionExpand
                            ? (CallState.instance.audioDevice == TUIAudioPlaybackDevice.speakerphone
                                ? CallKit_t("speakerIsOn")
                                : CallKit_t("speakerIsOff"))
                            : '',
                        textColor: Colors.white,
                        imgHeight: isFunctionExpand ? bigBtnHeight : smallBtnHeight,
                        onTap: () {
                          _handleSwitchAudioDevice();
                        },
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: isFunctionExpand
                          ? (MediaQuery.of(context).size.width * 3 / 4 - btnWidth / 2)
                          : (MediaQuery.of(context).size.width * 4 / 6 - btnWidth / 2),
                      bottom: isFunctionExpand ? bottomEdge + bigBtnHeight + edge : bottomEdge,
                      child: ExtendButton(
                        imgUrl: CallState.instance.isCameraOpen
                            ? "assets/images/camera_on.png"
                            : "assets/images/camera_off.png",
                        tips: isFunctionExpand
                            ? (CallState.instance.isCameraOpen
                                ? CallKit_t("cameraIsOn")
                                : CallKit_t("cameraIsOff"))
                            : '',
                        textColor: Colors.white,
                        imgHeight: isFunctionExpand ? bigBtnHeight : smallBtnHeight,
                        onTap: () {
                          _handleOpenCloseCamera();
                        },
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                      curve: curve,
                      duration: Duration(milliseconds: duration),
                      left: isFunctionExpand
                          ? (MediaQuery.of(context).size.width / 2 - btnWidth / 2)
                          : (MediaQuery.of(context).size.width * 5 / 6 - btnWidth / 2),
                      bottom: bottomEdge,
                      child: ExtendButton(
                        imgUrl: "assets/images/hangup.png",
                        textColor: Colors.white,
                        imgHeight: isFunctionExpand ? bigBtnHeight : smallBtnHeight,
                        onTap: () {
                          _handleHangUp(widget.close);
                        },
                        userAnimation: true,
                        duration: Duration(milliseconds: duration),
                      ),
                    ),
                    AnimatedPositioned(
                        curve: curve,
                        duration: Duration(milliseconds: duration),
                        left: (MediaQuery.of(context).size.width / 6 - smallBtnHeight / 2),
                        bottom: isFunctionExpand
                            ? bottomEdge + smallBtnHeight / 4 + 22
                            : bottomEdge + 22,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              isFunctionExpand = !isFunctionExpand;
                            });
                          },
                          child: Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..scale(1.0, isFunctionExpand ? 1.0 : -1.0, 1.0),
                            child: Image.asset(
                              'assets/images/arrow.png',
                              package: 'tencent_calls_uikit',
                              width: smallBtnHeight,
                            ),
                          ),
                        ))
                  ],
                ))));
  }

  _functionWidgetVerticalDragUpdate(DragUpdateDetails details) {
    if (details.delta.dy < 0 && !isFunctionExpand) {
      isFunctionExpand = true;
    } else if (details.delta.dy > 0 && isFunctionExpand) {
      isFunctionExpand = false;
    }
    setState(() {});
  }

  _openFloatWindow() async {
    if (Platform.isAndroid) {
      bool result = await TUICallKitPlatform.instance.hasFloatPermission();
      if (!result) {
        return;
      }
    }
    CallManager.instance.openFloatWindow();
    TUICallKitNavigatorObserver.getInstance().exitCallingPage();
  }

  _handleSwitchMic() async {
    if (CallState.instance.isMicrophoneMute) {
      CallState.instance.isMicrophoneMute = false;
      await CallManager.instance.openMicrophone();
    } else {
      CallState.instance.isMicrophoneMute = true;
      await CallManager.instance.closeMicrophone();
    }
    TUICore.instance.notifyEvent(setStateEventGroupCallUserWidgetRefresh);
    setState(() {});
  }

  _handleSwitchAudioDevice() async {
    if (CallState.instance.audioDevice == TUIAudioPlaybackDevice.earpiece) {
      CallState.instance.audioDevice = TUIAudioPlaybackDevice.speakerphone;
    } else {
      CallState.instance.audioDevice = TUIAudioPlaybackDevice.earpiece;
    }
    await CallManager.instance.selectAudioPlaybackDevice(CallState.instance.audioDevice);
    setState(() {});
  }

  _handleHangUp(Function close) async {
    await CallManager.instance.hangup();
    close();
  }

  _handleReject(Function close) async {
    await CallManager.instance.reject();
    close();
  }

  _handleAccept() async {
    PermissionResult permissionRequestResult = PermissionResult.requesting;
    if (Platform.isAndroid) {
      permissionRequestResult = await Permission.request(CallState.instance.mediaType);
    }
    if (permissionRequestResult == PermissionResult.granted || Platform.isIOS) {
      await CallManager.instance.accept();
      CallState.instance.selfUser.callStatus = TUICallStatus.accept;
    } else {
      CallManager.instance.showToast(CallKit_t("insufficientPermissions"));
    }
    setState(() {});
  }

  void _handleOpenCloseCamera() async {
    CallState.instance.isCameraOpen = !CallState.instance.isCameraOpen;
    if (CallState.instance.isCameraOpen) {
      await CallManager.instance
          .openCamera(CallState.instance.camera, CallState.instance.selfUser.viewID);
    } else {
      await CallManager.instance.closeCamera();
    }
    TUICore.instance.notifyEvent(setStateEventGroupCallUserWidgetRefresh);
    setState(() {});
  }
}
