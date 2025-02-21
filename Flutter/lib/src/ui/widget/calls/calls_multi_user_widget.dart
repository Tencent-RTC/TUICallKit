import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/src/call_define.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/call_videoview.dart';
import 'package:tencent_calls_uikit/src/impl/call_manager.dart';
import 'package:tencent_calls_uikit/src/impl/call_state.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/loading_animation.dart';
import 'package:tencent_calls_uikit/src/ui/widget/calls/calls_user_widget_data.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';
import 'package:tencent_calls_uikit/src/utils/tuple.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class CallsMultiUserWidget extends StatefulWidget {
  final int index;
  final User user;

  const CallsMultiUserWidget({Key? key, required this.index, required this.user}) : super(key: key);

  @override
  State<CallsMultiUserWidget> createState() => _CallsMultiUserWidgetState();
}

class _CallsMultiUserWidgetState extends State<CallsMultiUserWidget> {
  ITUINotificationCallback? refreshCallback;
  final _duration = const Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    refreshCallback = (arg) {
      if (mounted) {
        setState(() {});
      }
    };
    TUICore.instance.registerEvent(setStateEventGroupCallUserWidgetRefresh, refreshCallback);
  }

  @override
  void dispose() {
    super.dispose();
    TUICore.instance.unregisterEvent(setStateEventGroupCallUserWidgetRefresh, refreshCallback);
  }

  @override
  Widget build(BuildContext context) {
    final wh = _getWH(
        CallsMultiUserWidgetData.blockBigger, widget.index, CallsMultiUserWidgetData.blockCount);
    final Tuple<double, double> tl = _getTopLeft(
        CallsMultiUserWidgetData.blockBigger, widget.index, CallsMultiUserWidgetData.blockCount);

    bool isAvatarImage =
        (widget.user.id == CallState.instance.selfUser.id && !CallState.instance.isCameraOpen) ||
            (widget.user.id != CallState.instance.selfUser.id && !widget.user.videoAvailable);
    bool isShowLoadingImage = (widget.user.callStatus == TUICallStatus.waiting) &&
        (widget.user.id != CallState.instance.selfUser.id);
    bool isShowSpeaking = widget.user.playOutVolume != 0 &&
        ((widget.user.id == CallState.instance.selfUser.id) ||
            (widget.user.id != CallState.instance.selfUser.id &&
                widget.user.callStatus == TUICallStatus.accept));
    bool isShowLocalMute = (widget.user.id == CallState.instance.selfUser.id) &&
        CallState.instance.isMicrophoneMute;
    bool isShowSwitchCameraAndVB = CallsMultiUserWidgetData.blockBigger[widget.index]! &&
        (widget.user.id == CallState.instance.selfUser.id) &&
        (CallState.instance.isCameraOpen == true);
    bool isShowVBButton = CallsMultiUserWidgetData.blockBigger[widget.index]! &&
        (widget.user.id == CallState.instance.selfUser.id) &&
        (CallState.instance.isCameraOpen == true) &&
        (CallState.instance.showVirtualBackgroundButton == true);

    return AnimatedPositioned(
        width: wh,
        height: wh,
        top: tl.item1,
        left: tl.item2,
        duration: _duration,
        child: InkWell(
            onTap: () {
              CallsMultiUserWidgetData.blockBigger.forEach((key, value) {
                CallsMultiUserWidgetData.blockBigger[key] =
                (key == widget.index) ? !CallsMultiUserWidgetData.blockBigger[key]! : false;
              });

              CallsMultiUserWidgetData.initCanPlaceSquare(CallsMultiUserWidgetData.blockBigger,
                  CallState.instance.remoteUserList.length + 1);
              TUICore.instance.notifyEvent(setStateEventGroupCallUserWidgetRefresh);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                CallVideoView(
                  key: widget.user.key,
                  onPlatformViewCreated: (viewId) {
                    _onPlatformViewCreated(widget.user, viewId);
                  },
                ),
                Visibility(
                  visible: isAvatarImage,
                  child: Positioned.fill(
                    child: Image(
                      image: NetworkImage(
                          StringStream.makeNull(widget.user.avatar, Constants.defaultAvatar)),
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stackTrace) => Image.asset(
                        'assets/images/user_icon.png',
                        package: 'tencent_calls_uikit',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                Visibility(
                  visible: isShowLoadingImage,
                  child: Center(
                    child: LoadingAnimation(),
                  ),
                ),
                Visibility(
                  visible: isShowSwitchCameraAndVB,
                  child: Positioned(
                      right: 10,
                      bottom: 5,
                      width: 24,
                      height: 24,
                      child: InkWell(
                          onTap: () {
                            _handleSwitchCamera();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Positioned(
                                      width: 14,
                                      height: 14,
                                      child: Image.asset("assets/images/switch_camera.png",
                                          package: 'tencent_calls_uikit', fit: BoxFit.contain))
                                ],
                              )))),
                ),
                Visibility(
                  visible: isShowVBButton,
                  child: Positioned(
                      right: 50,
                      bottom: 5,
                      width: 24,
                      height: 24,
                      child: InkWell(
                          onTap: () {
                            _handleVirtualBackgroubd();
                          },
                          child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Stack(
                                alignment: AlignmentDirectional.center,
                                children: [
                                  Positioned(
                                      width: 14,
                                      height: 14,
                                      child: Image.asset("assets/images/virtual_background.png",
                                          package: 'tencent_calls_uikit', fit: BoxFit.fill))
                                ],
                              )))),
                ),
                Visibility(
                  visible: widget.user.networkQualityReminder,
                  child: Positioned(
                      right: _getNetworkBadHintRightMargin(),
                      bottom: 5,
                      width: 24,
                      height: 24,
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Image.asset(
                            "assets/images/network_bad.png",
                            package: 'tencent_calls_uikit',
                          ))),
                ),
                Positioned(
                  left: 5,
                  bottom: 5,
                  height: 24,
                  child: Row(
                    children: [
                      Visibility(
                        visible: CallsMultiUserWidgetData.blockBigger[widget.index]!,
                        child: Text(User.getUserDisplayName(widget.user),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Visibility(
                        visible: CallsMultiUserWidgetData.blockBigger[widget.index]!,
                        child: const SizedBox(
                          width: 10,
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Visibility(
                            visible: isShowSpeaking,
                            child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(
                                  "assets/images/speaking.png",
                                  package: 'tencent_calls_uikit',
                                )),
                          ),
                          Visibility(
                            visible: isShowLocalMute,
                            child: Container(
                                width: 24,
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.rectangle,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(
                                  "assets/images/audio_unavailable.png",
                                  package: 'tencent_calls_uikit',
                                )),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )));
  }

  double _getNetworkBadHintRightMargin() {
    return CallsMultiUserWidgetData.blockBigger[widget.index]!
        ? CallState.instance.isCameraOpen ? 90 : 10
        : 10;
  }

  _getWH(Map<int, bool> blockBigger, int index, int count) {
    if (_hasBigger(blockBigger)) {
      if (blockBigger[index]!) {
        if (count <= 4) {
          return MediaQuery.of(context).size.width;
        }
        return MediaQuery.of(context).size.width * 2 / 3;
      }

      return MediaQuery.of(context).size.width * 1 / 3;
    } else {
      if (count <= 4) {
        return MediaQuery.of(context).size.width / 2;
      }
      return MediaQuery.of(context).size.width * 1 / 3;
    }
  }

  Tuple<double, double> _getTopLeft(Map<int, bool> blockBigger, int index, int count) {
    bool has = _hasBigger(blockBigger);
    bool selfIsBigger = blockBigger[index]!;

    if (has) {
      if (selfIsBigger) {
        if (count <= 4) {
          return Tuple(0, 0);
        }

        int i = (index - 1) ~/ 3;
        int j = (index - 1) % 3;
        j = (j > 1) ? 1 : j;
        return Tuple(
            MediaQuery.of(context).size.width * i / 3, MediaQuery.of(context).size.width * j / 3);
      }

      for (int i = 0; i < CallsMultiUserWidgetData.canPlaceSquare.length; i++) {
        for (int j = 0; j < CallsMultiUserWidgetData.canPlaceSquare[i].length; j++) {
          if (CallsMultiUserWidgetData.canPlaceSquare[i][j] == true) {
            CallsMultiUserWidgetData.canPlaceSquare[i][j] = false;
            return Tuple(MediaQuery.of(context).size.width * i / 3,
                MediaQuery.of(context).size.width * j / 3);
          }
        }
      }
    }

    if (count == 2) {
      if (index == 1) {
        return Tuple(MediaQuery.of(context).size.width / 3, 0);
      }
      return Tuple(MediaQuery.of(context).size.width / 3, MediaQuery.of(context).size.width / 2);
    }
    if (count == 3) {
      if (index == 1) {
        return Tuple(0, 0);
      } else if (index == 2) {
        return Tuple(0, MediaQuery.of(context).size.width / 2);
      }
      return Tuple(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.width / 4);
    }
    if (count == 4) {
      if (index == 1) {
        return Tuple(0, 0);
      } else if (index == 2) {
        return Tuple(0, MediaQuery.of(context).size.width / 2);
      } else if (index == 3) {
        return Tuple(MediaQuery.of(context).size.width / 2, 0);
      }
      return Tuple(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.width / 2);
    }

    for (int i = 0; i < CallsMultiUserWidgetData.canPlaceSquare.length; i++) {
      for (int j = 0; j < CallsMultiUserWidgetData.canPlaceSquare[i].length; j++) {
        if (CallsMultiUserWidgetData.canPlaceSquare[i][j] == true) {
          CallsMultiUserWidgetData.canPlaceSquare[i][j] = false;
          return Tuple(
              MediaQuery.of(context).size.width * i / 3, MediaQuery.of(context).size.width * j / 3);
        }
      }
    }
    return Tuple(0, 0);
  }

  _hasBigger(Map<int, bool> blockBigger) {
    bool has = false;
    blockBigger.forEach((key, value) {
      if (value == true) {
        has = true;
      }
    });
    return has;
  }

  _onPlatformViewCreated(User user, int viewId) {
    debugPrint("_onPlatformViewCreated: user.id = ${user.id}, viewId = $viewId");
    if (user.id == CallState.instance.selfUser.id) {
      CallState.instance.selfUser.viewID = viewId;
      if (CallState.instance.isCameraOpen) {
        CallManager.instance.openCamera(CallState.instance.camera, viewId);
      }
    } else {
      CallManager.instance.startRemoteView(user.id, viewId);
    }
    user.viewID = viewId;
  }

  _handleSwitchCamera() async {
    if (TUICamera.front == CallState.instance.camera) {
      CallState.instance.camera = TUICamera.back;
    } else {
      CallState.instance.camera = TUICamera.front;
    }
    await CallManager.instance.switchCamera(CallState.instance.camera);
    TUICore.instance.notifyEvent(setStateEvent);
  }

  _handleVirtualBackgroubd() async {
    CallManager.instance.setBlurBackground(!CallState.instance.enableBlurBackground);
  }
}
