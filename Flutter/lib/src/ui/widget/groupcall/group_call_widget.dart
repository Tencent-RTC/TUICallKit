import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/platform/tuicall_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/ui/tuicall_navigator_observer.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/extent_button.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/timing_widget.dart';
import 'package:tencent_calls_uikit/src/ui/widget/groupcall/group_function_widget.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';

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
  @override
  void initState() {
    super.initState();
    if (TUICallMediaType.video == CallState.instance.mediaType) {
      CallState.instance.isCameraOpen = true;
    } else {
      CallState.instance.isCameraOpen = false;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
          _exitRoom();
          return true;
        },
        child: Container(
          color: _getBackgroundColor(),
          child: SafeArea(
            child: ConstrainedBox(
              constraints: const BoxConstraints.expand(),
              child: Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  _buildUserVideoList(),
                  _buildInviteUserButton(),
                  _buildFloatingWindowButton(),
                  _buildTimingAndHintWidget(),
                  _buildFunctionWidget(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildUserVideoList() {
    return Positioned(
      top: 0,
      left: 0,
      width: MediaQuery.of(context).size.width,
      child: (TUICallStatus.waiting == CallState.instance.selfUser.callStatus &&
              CallState.instance.selfUser.callRole == TUICallRole.called)
          ? _buildReceivedGroupCallWaitting()
          : _buildGroupCallList(),
    );
  }

  _buildInviteUserButton() {
    return Positioned(
      top: 15,
      right: 10,
      child: Visibility(
        visible: TUICallStatus.accept == CallState.instance.selfUser.callStatus ||
            TUICallRole.caller == CallState.instance.selfUser.callRole,
        child: ExtendButton(
          imgUrl: TUICallMediaType.audio == CallState.instance.mediaType
              ? "assets/images/add_user_dark.png"
              : "assets/images/add_user.png",
          imgHieght: 32,
          onTap: () {
            TUICallKitNavigatorObserver.getInstance().enterInviteUserPage();
          },
        ),
      ),
    );
  }

  _buildFloatingWindowButton() {
    return CallState.instance.enableFloatWindow
        ? Positioned(
            top: 15,
            left: 10,
            child: Visibility(
              visible: CallState.instance.enableFloatWindow,
              child: ExtendButton(
                imgUrl: (CallState.instance.mediaType == TUICallMediaType.audio)
                    ? "assets/images/floating_button_black.png"
                    : "assets/images/floating_button_white.png",
                imgHieght: 32,
                onTap: () {
                  _openFloatWindow();
                },
              ),
            ),
          )
        : const SizedBox();
  }

  _openFloatWindow() async {
    if (Platform.isAndroid) {
      bool result = await TUICallKitPlatform.instance.hasFloatPermission();
      if (!result) {
        return;
      }
    }
    TUICallKitPlatform.instance.startFloatWindow();
    TUICallKitNavigatorObserver.getInstance().exitCallingPage();
  }

  _buildFunctionWidget() {
    return Positioned(
      bottom: 50,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: GroupFunctionWidget.buildFunctionWidget(widget.close),
      ),
    );
  }

  _buildTimingAndHintWidget() {
    return Positioned(
        bottom: (TUICallMediaType.audio == CallState.instance.mediaType) ? 180 : 280,
        child: (TUICallStatus.accept == CallState.instance.selfUser.callStatus)
            ? const TimingWidget()
            : Visibility(
                visible: TUICallStatus.waiting == CallState.instance.selfUser.callStatus &&
                    TUICallRole.caller == CallState.instance.selfUser.callRole,
                child: Center(
                  child: Text(CallKit_t("正在等待对方接受邀请……"),
                      style: TextStyle(
                        color: _getTextColor(),
                        fontSize: 14,
                      )),
                ),
              ));
  }

  Widget _buildReceivedGroupCallWaitting() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
            margin: const EdgeInsets.only(top: 150),
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(
                image: NetworkImage(StringStream.makeNull(CallState.instance.caller.avatar, Constants.defaultAvatar)),
                fit: BoxFit.cover,
              ),
            )),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Text(
            StringStream.makeNull(CallState.instance.caller.nickname, CallState.instance.caller.id),
            style: TextStyle(fontSize: 24, color: _getTextColor()),
          ),
        ),
        Text(
          CallKit_t("邀请您进行多人通话……"),
          style: TextStyle(color: _getTextColor()),
        ),
        const SizedBox(
          height: 10,
        ),
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: Wrap(
            spacing: 5,
            runSpacing: 5,
            children: List.generate(CallState.instance.calleeList.length, ((index) {
              return Container(
                height: 30,
                width: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    image: NetworkImage(
                        StringStream.makeNull(CallState.instance.calleeList[index].avatar, Constants.defaultAvatar)),
                    fit: BoxFit.cover,
                  ),
                ),
              );
            })),
          ),
        )
      ],
    );
  }

  Widget _buildGroupCallList() {
    return Container(
      margin: const EdgeInsets.only(top: 80, left: 10, right: 10),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Wrap(
        spacing: 0,
        runSpacing: 0,
        direction: Axis.horizontal,
        alignment: CallState.instance.remoteUserList.length == 2 ? WrapAlignment.center : WrapAlignment.start,
        children: List.generate(CallState.instance.remoteUserList.length + 1, (index) {
          User user = _getUserByViewIndex(index);
          return SizedBox(
            width: _getVideoViewWidthHeight(),
            height: _getVideoViewWidthHeight(),
            child: Stack(
              alignment: Alignment.center, //指定未定位或部分定位widget的对齐方式
              children: <Widget>[
                Visibility(
                  visible: !user.videoAvailable,
                  child: Container(
                      width: _getVideoViewWidthHeight(),
                      height: _getVideoViewWidthHeight(),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(0),
                        image: DecorationImage(
                          image: NetworkImage(StringStream.makeNull(user.avatar, Constants.defaultAvatar)),
                          fit: BoxFit.cover,
                        ),
                      )),
                ),
                Visibility(
                  visible: TUICallMediaType.video == CallState.instance.mediaType,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 100),
                    opacity: user.videoAvailable ? 1.0 : 0,
                    child: TUIVideoView(
                      key: user.key,
                      onPlatformViewCreated: (viewId) {
                        _onPlatformViewCreated(user, viewId);
                      },
                    ),
                  ),
                ),
                Visibility(
                  visible: user.callStatus == TUICallStatus.waiting && user.id != CallState.instance.selfUser.id,
                  child: SizedBox(
                    width: 50,
                    height: 50,
                    child: Image.asset(
                      "assets/images/loading.gif",
                      package: 'tencent_calls_uikit',
                    ),
                  ),
                ),
                Positioned(
                    left: 5,
                    bottom: 5,
                    child: Text(StringStream.makeNull(user.nickname, user.id),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ))),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _onPlatformViewCreated(User user, int viewId) {
    debugPrint("_onPlatformViewCreated: user.id = ${user.id}, viewId = $viewId");
    if (user.id == CallState.instance.selfUser.id) {
      CallState.instance.isCameraOpen = true;
      CallState.instance.selfUser.videoAvailable = true;
      CallManager.instance.openCamera(CallState.instance.camera, viewId);
      CallState.instance.selfUser.viewID = viewId;
    } else {
      CallManager.instance.startRemoteView(user.id, viewId);
    }
    user.viewID = viewId;
  }

  /// -------2 * 2-------- View model ------3 * 3-------------
  /// |   me   | remote |  ---  |   me   | remote | remote |
  /// | remote | remote |  ---  | remote | remote | remote |
  /// ------------------------  | remote | remote | remote |
  /// --------------------------------------------------------
  double _getVideoViewWidthHeight() {
    int userCount = CallState.instance.remoteUserList.length + 1;
    if (userCount > 4) {
      return ((MediaQuery.of(context).size.width - 20) / 3);
    } else {
      return ((MediaQuery.of(context).size.width - 20) / 2);
    }
  }

  User _getUserByViewIndex(int index) {
    if (index == 0) {
      if (TUICallMediaType.video == CallState.instance.mediaType) {
        CallState.instance.selfUser.videoAvailable = CallState.instance.isCameraOpen;
      } else {
        CallState.instance.selfUser.videoAvailable = false;
      }
      return CallState.instance.selfUser;
    } else {
      return CallState.instance.remoteUserList[index - 1];
    }
  }

  _exitRoom() {}

  Color _getBackgroundColor() {
    return (TUICallMediaType.audio == CallState.instance.mediaType) ? Colors.white : Colors.black;
  }

  Color _getTextColor() {
    return (TUICallMediaType.audio == CallState.instance.mediaType) ? Colors.black : Colors.white;
  }
}
