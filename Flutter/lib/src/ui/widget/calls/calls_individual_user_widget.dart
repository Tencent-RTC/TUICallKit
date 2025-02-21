import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/src/call_define.dart';
import 'package:tencent_calls_uikit/src/ui/widget/calls/calls_user_widget_data.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/call_videoview.dart';
import 'package:tencent_calls_uikit/src/impl/call_manager.dart';
import 'package:tencent_calls_uikit/src/impl/call_state.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/data/user.dart';
import 'package:tencent_calls_uikit/src/utils/string_stream.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class CallsIndividualUserWidget extends StatefulWidget {
  final Function close;

  const CallsIndividualUserWidget({
    Key? key,
    required this.close,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _CallsIndividualUserWidgetState();
}

class _CallsIndividualUserWidgetState extends State<CallsIndividualUserWidget> {
  ITUINotificationCallback? setSateCallBack;
  final Key _localKey = GlobalKey(debugLabel: "local");
  final Key _remoteKey = GlobalKey(debugLabel: "remote");

  late final Widget _localVideoView = CallVideoView(
      key: _localKey,
      onPlatformViewCreated: (viewId) {
        CallState.instance.selfUser.viewID = viewId;
        if (CallState.instance.isCameraOpen) {
          CallManager.instance.openCamera(CallState.instance.camera, viewId);
        }
      });

  late final Widget _remoteVideoView = CallVideoView(
      key: _remoteKey,
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
            CallsIndividualUserWidgetData.isOnlyShowBigVideoView ? const SizedBox() : _buildSmallVideoWidget(),
            CallsIndividualUserWidgetData.isOnlyShowBigVideoView ? const SizedBox() : _buildUserInfoWidget(),
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
              textScaleFactor: 1.0,
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
          CallsIndividualUserWidgetData.isOnlyShowBigVideoView = !CallsIndividualUserWidgetData.isOnlyShowBigVideoView;
          TUICore.instance.notifyEvent(setStateEventGroupCallUserWidgetRefresh);
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
        top: CallsIndividualUserWidgetData.smallViewTop - 40,
        right: CallsIndividualUserWidgetData.smallViewRight,
        child: GestureDetector(
          onTap: () {
            _changeVideoView();
          },
          onPanUpdate: (DragUpdateDetails e) {
            if (CallState.instance.mediaType == TUICallMediaType.video) {
              CallsIndividualUserWidgetData.smallViewRight -= e.delta.dx;
              CallsIndividualUserWidgetData.smallViewTop += e.delta.dy;
              if (CallsIndividualUserWidgetData.smallViewTop < 100) {
                CallsIndividualUserWidgetData.smallViewTop = 100;
              }
              if (CallsIndividualUserWidgetData.smallViewTop > MediaQuery.of(context).size.height - 216) {
                CallsIndividualUserWidgetData.smallViewTop = MediaQuery.of(context).size.height - 216;
              }
              if (CallsIndividualUserWidgetData.smallViewRight < 0) {
                CallsIndividualUserWidgetData.smallViewRight = 0;
              }
              if (CallsIndividualUserWidgetData.smallViewRight > MediaQuery.of(context).size.width - 110) {
                CallsIndividualUserWidgetData.smallViewRight = MediaQuery.of(context).size.width - 110;
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

  _getBackgroundColor() {
    return CallState.instance.mediaType == TUICallMediaType.audio
        ? const Color(0xFFF2F2F2)
        : const Color(0xFF444444);
  }

  _getTextColor() {
    return Colors.white;
  }
}
