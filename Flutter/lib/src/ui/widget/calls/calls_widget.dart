import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/src/call_define.dart';
import 'package:tencent_calls_uikit/src/impl/call_manager.dart';
import 'package:tencent_calls_uikit/src/impl/call_state.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/platform/call_kit_platform_interface.dart';
import 'package:tencent_calls_uikit/src/ui/call_navigator_observer.dart';
import 'package:tencent_calls_uikit/src/ui/widget/calls/calls_function_widget.dart';
import 'package:tencent_calls_uikit/src/ui/widget/calls/calls_user_widget_data.dart';
import 'package:tencent_calls_uikit/src/ui/widget/calls/calls_multi_user_widget.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/timing_widget.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

import 'calls_individual_user_widget.dart';

class CallsWidget extends StatefulWidget {
  static bool isFunctionExpand = true;
  final Function close;

  const CallsWidget({
    Key? key,
    required this.close,
  }) : super(key: key);

  State<CallsWidget> createState() => _CallsWidgetState();
}

class _CallsWidgetState extends State<CallsWidget> with TickerProviderStateMixin {
  late ITUINotificationCallback setSateCallBack;
  late ITUINotificationCallback groupCallUserWidgetRefreshCallback;
  late final List<CallsMultiUserWidget> _userViewWidgets = [];
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _fadeOutAnimation;
  bool isDirectMulti = false;
  bool isMultiPerson = false;
  bool isShowInvite = false;


  _initUsersViewWidget() {
    CallsIndividualUserWidgetData.isOnlyShowBigVideoView = false;
    CallsMultiUserWidgetData.initBlockCounter();
    CallsMultiUserWidgetData.updateBlockBigger(CallState.instance.remoteUserList.length + 1);
    CallsMultiUserWidgetData.initCanPlaceSquare(
        CallsMultiUserWidgetData.blockBigger, CallState.instance.remoteUserList.length + 1);
    _userViewWidgets.clear();

    CallsMultiUserWidgetData.blockCount++;
    _userViewWidgets.add(CallsMultiUserWidget(
        index: CallsMultiUserWidgetData.blockCount, user: CallState.instance.selfUser));

    for (var remoteUser in CallState.instance.remoteUserList) {
      CallsMultiUserWidgetData.blockCount++;
      _userViewWidgets
          .add(CallsMultiUserWidget(index: CallsMultiUserWidgetData.blockCount, user: remoteUser));
    }
    setState(() {
      if (!isMultiPerson) {
        isMultiPerson = true;
        _controller.forward();
      }
    });
  }

  _initAnimation() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(_controller);
  }

  @override
  void initState() {
    super.initState();
    CallsWidget.isFunctionExpand = true;
    CallsIndividualUserWidgetData.initIndividualUserWidgetData();
    if (CallState.instance.groupId != '' || CallState.instance.scene == TUICallScene.groupCall) {
      isDirectMulti = true;
      isShowInvite = true;
    }

    _initAnimation();

    setSateCallBack = (arg) {
      if (mounted) {
        if (isMultiPerson || CallState.instance.remoteUserList.length >= 2) {
          _initUsersViewWidget();
        } else {
          setState(() {});
        }
      }
    };

    groupCallUserWidgetRefreshCallback = (arg) {
      if (mounted) {
        if (CallsMultiUserWidgetData.hasBiggerSquare()) {
          CallsWidget.isFunctionExpand = false;
        } else {
          CallsWidget.isFunctionExpand = true;
        }
        setState(() {});
      }
    };

    TUICore.instance.registerEvent(setStateEvent, setSateCallBack);
    TUICore.instance
        .registerEvent(setStateEventGroupCallUserWidgetRefresh, groupCallUserWidgetRefreshCallback);


    CallsMultiUserWidgetData.initBlockBigger();
    if (isDirectMulti || CallState.instance.remoteUserList.length >= 2) {
      isDirectMulti = true;
      _initUsersViewWidget();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
    TUICore.instance.unregisterEvent(setStateEvent, setSateCallBack);
    TUICore.instance.unregisterEvent(
        setStateEventGroupCallUserWidgetRefresh, groupCallUserWidgetRefreshCallback);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // padding: const EdgeInsets.only(top: 40),
        color: const Color.fromRGBO(45, 45, 45, 1.0),
        child: Stack(
          alignment: Alignment.center,
          fit: StackFit.expand,
          children: <Widget>[
            isDirectMulti
                ? _buildMultiUserVideoList()
                : Visibility(
                    visible: _fadeInAnimation.value != 0 || isMultiPerson,
                    child: FadeTransition(
                      opacity: _fadeInAnimation,
                      child: _buildMultiUserVideoList(),
                    ),
                  ),
            Visibility(
              visible: !isDirectMulti && _fadeOutAnimation.value != 0 || !isMultiPerson,
              child: FadeTransition(
                opacity: _fadeOutAnimation,
                child: CallsIndividualUserWidget(close: widget.close),
              ),
            ),

            CallsIndividualUserWidgetData.isOnlyShowBigVideoView ? const SizedBox() : _buildTopWidget(),
            CallsIndividualUserWidgetData.isOnlyShowBigVideoView ? const SizedBox() : _buildFunctionWidget(),
          ],
        ),
      ),
    );
  }
  _buildMultiUserVideoList() {
    return (TUICallStatus.waiting == CallState.instance.selfUser.callStatus &&
        CallState.instance.selfUser.callRole == TUICallRole.called)
        ? _buildReceivedGroupCallWaitting()
        : _buildGroupCallView();
  }

  _buildReceivedGroupCallWaitting() {
    return SizedBox(
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
    return Container(
        margin: const EdgeInsets.only(top: 90),
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
      visible: isShowInvite &&
          (TUICallStatus.accept == CallState.instance.selfUser.callStatus ||
          TUICallRole.caller == CallState.instance.selfUser.callRole),
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
        top: 55,
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
    return Positioned(
      left: 0,
      bottom: 0,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Visibility(
            visible: !isDirectMulti && _fadeOutAnimation.value != 0 || !isMultiPerson,
            child: FadeTransition(opacity: _fadeOutAnimation,
              child:
              Container(
                margin: const EdgeInsets.only(bottom: 50),
                child: CallsFunctionWidget.buildIndividualFunctionWidget(widget.close),
              ),
            ),
          ),
          isDirectMulti
              ? CallsFunctionWidget.buildMultiCallFunctionWidget(context, widget.close)
              : Visibility(
                  visible: _fadeInAnimation.value != 0 || isMultiPerson,
                  child: FadeTransition(
                    opacity: _fadeInAnimation,
                    child: CallsFunctionWidget.buildMultiCallFunctionWidget(context, widget.close),
                  ),
                ),
        ],
      ),
    );
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
}