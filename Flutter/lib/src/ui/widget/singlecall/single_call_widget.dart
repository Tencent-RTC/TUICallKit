import 'dart:async';
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
import 'package:tencent_calls_uikit/src/ui/widget/common/timing_widget.dart';
import 'package:tencent_calls_uikit/src/ui/widget/singlecall/single_function_widget.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class SingleCallWidget extends StatefulWidget {
  final Function close;

  const SingleCallWidget({
    Key? key,
    required this.close,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SingleCallWidgetState();
}

class _SingleCallWidgetState extends State<SingleCallWidget> {
  ITUINotificationCallback? setSateCallBack;
  bool _hadShowAcceptText = false;
  bool _isShowAcceptText = false;
  double _smallViewTop = 128;
  double _smallViewRight = 20;
  bool _isOnlyShowBigVideoView = false;

  final Widget _localVideoView = TUIVideoView(
      key: CallState.instance.selfUser.key,
      onPlatformViewCreated: (viewId) {
        CallState.instance.selfUser.viewID = viewId;
        if (CallState.instance.isCameraOpen) {
          CallManager.instance.openCamera(CallState.instance.camera, viewId);
        }
      });

  final Widget _remoteVideoView = TUIVideoView(
      key: CallState.instance.remoteUserList.isEmpty
          ? GlobalKey()
          : CallState.instance.remoteUserList[0].key,
      onPlatformViewCreated: (viewId) {
        CallState.instance.remoteUserList[0].viewID = viewId;
        CallManager.instance.startRemoteView(CallState.instance.remoteUserList[0].id, viewId);
      });

  @override
  void initState() {
    super.initState();
    setSateCallBack = (arg) {
      if (mounted) {
        setState(() {});
      }
    };
    TUICore.instance.registerEvent(setStateEvent, setSateCallBack);
  }

  @override
  dispose() {
    super.dispose();
    TUICore.instance.unregisterEvent(setStateEvent, setSateCallBack);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
          color: _getBackgroundColor(),
          child: Stack(
            alignment: Alignment.topLeft,
            fit: StackFit.expand,
            children: [
              _buildBackground(),
              _buildBigVideoWidget(),
              _isOnlyShowBigVideoView ? const SizedBox() : _buildSmallVideoWidget(),
              _isOnlyShowBigVideoView ? const SizedBox() : _buildFloatingWindowBtnWidget(),
              _isOnlyShowBigVideoView ? const SizedBox() : _buildTimerWidget(),
              _isOnlyShowBigVideoView ? const SizedBox() : _buildUserInfoWidget(),
              _isOnlyShowBigVideoView ? const SizedBox() : _buildHintTextWidget(),
              _isOnlyShowBigVideoView ? const SizedBox() : _buildFunctionButtonWidget(),
            ],
          ),
        ),
    );
  }

  _buildBackground() {
    var avatar = '';
    if (CallState.instance.remoteUserList.isNotEmpty) {
      avatar = StringStream.makeNull(
          CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        Image(
          height: double.infinity,
          image: NetworkImage(avatar),
          fit: BoxFit.cover,
          errorBuilder: (ctx, err, stackTrace) => Image.asset(
            'assets/images/user_icon.png',
            package: 'tencent_calls_uikit',
          ),
        ),
        Opacity(
            opacity: 1,
            child: Container(
              color: const Color.fromRGBO(45, 45, 45, 0.9),
            ))
      ],
    );
  }

  _buildFloatingWindowBtnWidget() {
    return CallState.instance.enableFloatWindow
        ? Positioned(
            left: 12,
            top: 52,
            child: InkWell(
                onTap: () => _openFloatWindow(),
                child: Padding(
                  padding: const EdgeInsets.all(12),
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
  }

  _buildTimerWidget() {
    return Positioned(
      left: 0,
      top: 66,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CallState.instance.selfUser.callStatus == TUICallStatus.accept
              ? Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: const TimingWidget(),
                )
              : const SizedBox(),
        ],
      ),
    );
  }

  _buildUserInfoWidget() {
    var showName = '';
    var avatar = '';
    if (CallState.instance.remoteUserList.isNotEmpty) {
      showName = User.getUserDisplayName(CallState.instance.remoteUserList[0]);
      avatar = StringStream.makeNull(
          CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
    }

    final userInfoWidget = Positioned(
        top: MediaQuery.of(context).size.height / 4,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 110,
              width: 110,
              clipBehavior: Clip.hardEdge,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Image(
                image: NetworkImage(avatar),
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stackTrace) => Image.asset(
                  'assets/images/user_icon.png',
                  package: 'tencent_calls_uikit',
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              showName,
              style: TextStyle(
                fontSize: 24,
                color: _getTextColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ));

    if (CallState.instance.mediaType == TUICallMediaType.video &&
        CallState.instance.selfUser.callStatus == TUICallStatus.accept) {
      return const SizedBox();
    }
    return userInfoWidget;
  }

  _buildHintTextWidget() {
    bool isWaiting = CallState.instance.selfUser.callStatus == TUICallStatus.waiting ? true : false;

    if (CallState.instance.selfUser.callRole == TUICallRole.caller &&
        CallState.instance.selfUser.callStatus == TUICallStatus.accept &&
        CallState.instance.timeCount < 1) {
      if (!_hadShowAcceptText) {
        _isShowAcceptText = true;
        Timer(const Duration(seconds: 1), () {
          setState(() {
            _isShowAcceptText = false;
            _hadShowAcceptText = true;
          });
        });
      }
    }

    return Positioned(
        top: MediaQuery.of(context).size.height * 2 / 3,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isWaiting
                ? Text(
                    CallState.instance.selfUser.callRole == TUICallRole.caller
                        ? CallKit_t("waitingForInvitationAcceptance")
                        : CallState.instance.mediaType == TUICallMediaType.audio
                            ? CallKit_t("invitedToAudioCall")
                            : CallKit_t("invitedToVideoCall"),
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w400, color: _getTextColor()),
                  )
                : const SizedBox(),
            _isShowAcceptText
                ? Text(
                    CallKit_t('connected'),
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600, color: _getTextColor()),
                  )
                : const SizedBox(),
          ],
        ));
  }

  _buildFunctionButtonWidget() {
    return Positioned(
      left: 0,
      bottom: 50,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [SingleFunctionWidget.buildFunctionWidget(widget.close)],
      ),
    );
  }

  Widget _buildBigVideoWidget() {
    var remoteAvatar = '';
    var remoteVideoAvailable = false;
    if (CallState.instance.remoteUserList.isNotEmpty) {
      remoteAvatar = StringStream.makeNull(
          CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
      remoteVideoAvailable = CallState.instance.remoteUserList[0].videoAvailable;
    }
    var selfAvatar =
        StringStream.makeNull(CallState.instance.selfUser.avatar, Constants.defaultAvatar);
    var isCameraOpen = CallState.instance.isCameraOpen;

    if (CallState.instance.mediaType == TUICallMediaType.audio) {
      return const SizedBox();
    }

    bool isLocalViewBig = true;
    if (CallState.instance.selfUser.callStatus == TUICallStatus.waiting) {
      isLocalViewBig = true;
    } else {
      if (CallState.instance.isChangedBigSmallVideo) {
        isLocalViewBig = false;
      } else {
        isLocalViewBig = true;
      }
    }

    return CallState.instance.mediaType == TUICallMediaType.video
        ? InkWell(
            onTap: () {
              setState(() {
                _isOnlyShowBigVideoView = !_isOnlyShowBigVideoView;
              });
            },
            child: Container(
              color: Colors.black54,
              child: Stack(
                children: [
                  CallState.instance.selfUser.callStatus == TUICallStatus.accept
                      ? Visibility(
                          visible: (isLocalViewBig ? !isCameraOpen : !remoteVideoAvailable),
                          child: Center(
                              child: Container(
                            height: 80,
                            width: 80,
                            clipBehavior: Clip.hardEdge,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            child: Image(
                              image: NetworkImage(isLocalViewBig ? selfAvatar : remoteAvatar),
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, stackTrace) => Image.asset(
                                'assets/images/user_icon.png',
                                package: 'tencent_calls_uikit',
                              ),
                            ),
                          )),
                        )
                      : Container(),
                  Opacity(
                      opacity: isLocalViewBig
                          ? _getOpacityByVis(isCameraOpen)
                          : _getOpacityByVis(remoteVideoAvailable),
                      child: isLocalViewBig ? _localVideoView : _remoteVideoView)
                ],
              ),
            ))
        : Container();
  }

  Widget _buildSmallVideoWidget() {
    if (CallState.instance.mediaType == TUICallMediaType.audio) {
      return const SizedBox();
    }
    bool isRemoteViewSmall = true;

    if (CallState.instance.selfUser.callStatus == TUICallStatus.accept) {
      if (CallState.instance.isChangedBigSmallVideo) {
        isRemoteViewSmall = false;
      } else {
        isRemoteViewSmall = true;
      }
    }

    var remoteAvatar = '';
    var remoteVideoAvailable = false;
    var remoteAudioAvailable = false;

    if (CallState.instance.remoteUserList.isNotEmpty) {
      remoteAvatar = StringStream.makeNull(
          CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
      remoteVideoAvailable = CallState.instance.remoteUserList[0].videoAvailable;
      remoteAudioAvailable = CallState.instance.remoteUserList[0].audioAvailable;
    }
    var selfAvatar =
        StringStream.makeNull(CallState.instance.selfUser.avatar, Constants.defaultAvatar);
    var isCameraOpen = CallState.instance.isCameraOpen;

    var smallVideoWidget = CallState.instance.selfUser.callStatus == TUICallStatus.accept
        ? Container(
            height: 216,
            width: 110,
            color: Colors.black54,
            child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                Visibility(
                  visible: (isRemoteViewSmall ? !remoteVideoAvailable : !isCameraOpen),
                  child: Center(
                    child: Container(
                      height: 80,
                      width: 80,
                      clipBehavior: Clip.hardEdge,
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8)),
                      ),
                      child: Image(
                        image: NetworkImage(isRemoteViewSmall ? remoteAvatar : selfAvatar),
                        fit: BoxFit.cover,
                        errorBuilder: (ctx, err, stackTrace) => Image.asset(
                          'assets/images/user_icon.png',
                          package: 'tencent_calls_uikit',
                        ),
                      ),
                    ),
                  ),
                ),
                Opacity(
                    opacity: isRemoteViewSmall
                        ? _getOpacityByVis(remoteVideoAvailable)
                        : _getOpacityByVis(isCameraOpen),
                    child: isRemoteViewSmall ? _remoteVideoView : _localVideoView),
                Positioned(
                  left: 5,
                  bottom: 5,
                  width: 20,
                  height: 20,
                  child: (isRemoteViewSmall && !remoteAudioAvailable)
                      ? Image.asset(
                          'assets/images/audio_unavailable_grey.png',
                          package: 'tencent_calls_uikit',
                        )
                      : const SizedBox(),
                )
              ],
            ))
        : Container();

    return Positioned(
        top: _smallViewTop - 40,
        right: _smallViewRight,
        child: GestureDetector(
          onTap: () {
            _changeVideoView();
          },
          onPanUpdate: (DragUpdateDetails e) {
            if (CallState.instance.mediaType == TUICallMediaType.video) {
              _smallViewRight -= e.delta.dx;
              _smallViewTop += e.delta.dy;
              if (_smallViewTop < 100) {
                _smallViewTop = 100;
              }
              if (_smallViewTop > MediaQuery.of(context).size.height - 216) {
                _smallViewTop = MediaQuery.of(context).size.height - 216;
              }
              if (_smallViewRight < 0) {
                _smallViewRight = 0;
              }
              if (_smallViewRight > MediaQuery.of(context).size.width - 110) {
                _smallViewRight = MediaQuery.of(context).size.width - 110;
              }
              setState(() {});
            }
          },
          child: SizedBox(
            width: 110,
            child: smallVideoWidget,
          ),
        ));
  }

  _changeVideoView() {
    if (CallState.instance.mediaType == TUICallMediaType.audio ||
        CallState.instance.selfUser.callStatus == TUICallStatus.waiting) {
      return;
    }

    setState(() {
      CallState.instance.isChangedBigSmallVideo = !CallState.instance.isChangedBigSmallVideo;
    });
  }

  double _getOpacityByVis(bool vis) {
    return vis ? 1.0 : 0;
  }

  _openFloatWindow() async {
    if (Platform.isAndroid) {
      bool result = await TUICallKitPlatform.instance.hasFloatPermission();
      if (!result) {
        return;
      }
    }
    TUICallKitNavigatorObserver.getInstance().exitCallingPage();
    CallManager.instance.openFloatWindow();
  }

  _getBackgroundColor() {
    return CallState.instance.mediaType == TUICallMediaType.audio
        ? const Color(0xFFF2F2F2)
        : const Color(0xFF444444);
  }

  _getTextColor() {
    return Colors.white;
  }
}
