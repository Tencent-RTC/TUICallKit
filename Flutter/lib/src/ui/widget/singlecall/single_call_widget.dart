import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/timing_widget.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_navigator_observer.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/ui/widget/singlecall/single_function_widget.dart';
import 'package:tencent_calls_uikit/src/utils/event_bus.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';

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
  double _smallViewTop = 128;
  double _smallViewRight = 20;

  late EventCallback callBeginCallBack = (arg) {
    Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _changeVideoView();
      timer.cancel();
    });
  };

  final Widget _localVideoView = TUIVideoView(
      key: CallState.instance.selfUser.key,
      onPlatformViewCreated: (viewId) {
        CallState.instance.selfUser.viewID = viewId;
        CallManager.instance.openCamera(CallState.instance.camera, viewId);
      });

  final Widget _remoteVideoView = TUIVideoView(
      key: CallState.instance.remoteUserList[0].key,
      onPlatformViewCreated: (viewId) {
        CallState.instance.remoteUserList[0].viewID = viewId;
        CallManager.instance.startRemoteView(CallState.instance.remoteUserList[0].id, viewId);
      });

  @override
  void initState() {
    super.initState();

    if (CallState.instance.mediaType == TUICallMediaType.video) {
      CallState.instance.isCameraOpen = true;
    }
    CallState.instance.isChangedBigSmallVideo = false;

    eventBus.register(setStateEventOnCallBegin, callBeginCallBack);
  }

  @override
  dispose() {
    super.dispose();
    CallState.instance.isChangedBigSmallVideo = false;
    eventBus.unregister(setStateEventOnCallBegin, callBeginCallBack);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          return true;
        },
        child: Container(
          color: _getBackgroundColor(),
          child: Stack(
            alignment: Alignment.topLeft,
            fit: StackFit.expand,
            children: [
              _buildBigVideoWidget(),
              _buildSmallVideoWidget(),
              _buildFloatingWindowBtnWidget(),
              _buildUserInfoWidget(),
              _buildFunctionButtonWidget(),
            ],
          ),
        ),
      ),
    );
  }

  _buildFloatingWindowBtnWidget() {
    return CallState.instance.enableFloatWindow
        ? Positioned(
            left: 24,
            top: 64,
            width: 30,
            height: 30,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    child: Image.asset(
                      CallState.instance.mediaType == TUICallMediaType.audio
                          ? 'assets/images/floating_button_black.png'
                          : 'assets/images/floating_button_white.png',
                      package: 'tencent_calls_uikit',
                    ),
                    onTap: () {
                      _openFlaotWindow();
                    },
                  )
                ]),
          )
        : const SizedBox();
  }

  _buildUserInfoWidget() {
    var showName = '';
    var avatar = '';
    if (CallState.instance.remoteUserList.isNotEmpty) {
      showName = StringStream.makeNull(CallState.instance.remoteUserList[0].nickname, Constants.defaultNickname);

      avatar = StringStream.makeNull(CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
    }

    bool isWaiting = CallState.instance.selfUser.callStatus == TUICallStatus.waiting ? true : false;

    var videoUserInfoWidget = Positioned(
        top: _smallViewTop - 60,
        right: _smallViewRight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: isWaiting
              ? [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        showName,
                        style: TextStyle(
                          fontSize: 24,
                          color: _getTextColor(),
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.end,
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        CallState.instance.selfUser.callRole == TUICallRole.caller
                            ? CallKit_t("正在等待对方接受邀请……")
                            : CallKit_t("邀请您进行通话……"),
                        style: TextStyle(fontSize: 12, color: _getTextColor()),
                        textAlign: TextAlign.end,
                      )
                    ],
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Container(
                      height: 80,
                      width: 80,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(avatar),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container()),
                ]
              : [],
        ));

    var audioUserInfoWidget = Positioned(
        top: _smallViewTop,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: 110,
                width: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(avatar),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container()),
            const SizedBox(height: 20),
            Text(
              showName,
              style: TextStyle(
                fontSize: 24,
                color: _getTextColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            isWaiting
                ? Text(
                    CallState.instance.selfUser.callRole == TUICallRole.caller
                        ? CallKit_t("正在等待对方接受邀请……")
                        : CallKit_t("邀请您进行通话……"),
                    style: TextStyle(fontSize: 12, color: _getTextColor()),
                  )
                : const SizedBox()
          ],
        ));

    return CallState.instance.mediaType == TUICallMediaType.audio ? audioUserInfoWidget : videoUserInfoWidget;
  }

  _buildFunctionButtonWidget() {
    var timerText = Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: const TimingWidget(),
    );

    var buttomWidget = Positioned(
      left: 0,
      bottom: 50,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CallState.instance.selfUser.callStatus == TUICallStatus.accept ? timerText : const SizedBox(),
          SingleFunctionWidget.buildFunctionWidget(widget.close)
        ],
      ),
    );
    return buttomWidget;
  }

  // 占满全屏幕的大窗
  Widget _buildBigVideoWidget() {
    var remoteAvatar = '';
    var remoteVideoAvailable = false;
    if (CallState.instance.remoteUserList.isNotEmpty) {
      remoteAvatar = StringStream.makeNull(CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
      remoteVideoAvailable = CallState.instance.remoteUserList[0].videoAvailable;
    }
    var selfAvatar = StringStream.makeNull(CallState.instance.selfUser.avatar, Constants.defaultAvatar);
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
        ? Container(
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
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(0),
                                image: DecorationImage(
                                  image: NetworkImage(isLocalViewBig ? selfAvatar : remoteAvatar),
                                  fit: BoxFit.cover,
                                ),
                              )),
                        ),
                      )
                    : Container(),
                Opacity(
                    opacity: isLocalViewBig ? _getOpacityByVis(isCameraOpen) : _getOpacityByVis(remoteVideoAvailable),
                    child: isLocalViewBig ? _localVideoView : _remoteVideoView)
              ],
            ),
          )
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
    if (CallState.instance.remoteUserList.isNotEmpty) {
      remoteAvatar = StringStream.makeNull(CallState.instance.remoteUserList[0].avatar, Constants.defaultAvatar);
      remoteVideoAvailable = CallState.instance.remoteUserList[0].videoAvailable;
    }
    var selfAvatar = StringStream.makeNull(CallState.instance.selfUser.avatar, Constants.defaultAvatar);
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
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(0),
                          image: DecorationImage(
                            image: NetworkImage(isRemoteViewSmall ? remoteAvatar : selfAvatar),
                            fit: BoxFit.cover,
                          ),
                        )),
                  ),
                ),
                Opacity(
                    opacity:
                        isRemoteViewSmall ? _getOpacityByVis(remoteVideoAvailable) : _getOpacityByVis(isCameraOpen),
                    child: isRemoteViewSmall ? _remoteVideoView : _localVideoView)
              ],
            ))
        : Container();

    return Positioned(
        top: _smallViewTop - 60,
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

  _openFlaotWindow() async {
    if (Platform.isAndroid) {
      bool result = await TUICallKitPlatform.instance.hasFloatPermission();
      if (!result) {
        return;
      }
    }
    TUICallKitNavigatorObserver.getInstance().exitCallingPage();
    TUICallKitPlatform.instance.startFloatWindow();
  }

  _getBackgroundColor() {
    return CallState.instance.mediaType == TUICallMediaType.audio ? const Color(0xFFF2F2F2) : const Color(0xFF444444);
  }

  _getTextColor() {
    return CallState.instance.mediaType == TUICallMediaType.audio ? Colors.black : Colors.white;
  }
}
