import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/call_manager.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/ui/widget/common/extent_button.dart';
import 'package:tencent_calls_uikit/src/utils/event_bus.dart';
import 'package:tencent_calls_uikit/src/utils/permission_request.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class SingleFunctionWidget {
  static Widget buildFunctionWidget(Function close) {
    if (TUICallStatus.waiting == CallState.instance.selfUser.callStatus) {
      if (TUICallRole.caller == CallState.instance.selfUser.callRole) {
        if (TUICallMediaType.audio == CallState.instance.mediaType) {
          return _buildAudioCallerWaitingAndAcceptedView(close);
        } else {
          return _buildVideoCallerWaitingView(close);
        }
      } else {
        return _buildAudioAndVideoCalleeWaitingView(close);
      }
    } else if (TUICallStatus.accept == CallState.instance.selfUser.callStatus) {
      if (TUICallMediaType.audio == CallState.instance.mediaType) {
        return _buildAudioCallerWaitingAndAcceptedView(close);
      } else {
        return _buildVideoCallerAndCalleeAcceptedView(close);
      }
    } else {
      return Container();
    }
  }

  static Widget _buildAudioCallerWaitingAndAcceptedView(Function close) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ExtendButton(
          imgUrl: CallState.instance.isMicrophoneMute ? "assets/images/mute_on.png" : "assets/images/mute.png",
          tips: CallKit_t("麦克风"),
          textColor: _getTextColor(),
          imgHieght: 52,
          onTap: () {
            _handleSwitchMic();
          },
        ),
        ExtendButton(
          imgUrl: "assets/images/hangup.png",
          tips: CallKit_t("挂断"),
          textColor: _getTextColor(),
          imgHieght: 64,
          onTap: () {
            _handleHangUp(close);
          },
        ),
        ExtendButton(
          imgUrl: CallState.instance.audioDevice == TUIAudioPlaybackDevice.speakerphone
              ? "assets/images/handsfree_on.png"
              : "assets/images/handsfree.png",
          tips: CallState.instance.audioDevice == TUIAudioPlaybackDevice.speakerphone
              ? CallKit_t("扬声器")
              : CallKit_t("听筒"),
          imgHieght: 52,
          textColor: _getTextColor(),
          onTap: () {
            _handleSwitchAudioDevice();
          },
        ),
      ],
    );
  }

  static Widget _buildVideoCallerWaitingView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ExtendButton(
          imgUrl: "assets/images/switch2audio.png",
          imgHieght: 20,
          tips: CallKit_t("切到语音通话"),
          onTap: () {
            _switchToAudio();
          },
          textColor: _getTextColor(),
        ),
        const SizedBox(
          height: 40,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          const SizedBox(
            width: 42,
          ),
          ExtendButton(
            imgUrl: "assets/images/hangup.png",
            tips: CallKit_t("挂断"),
            textColor: _getTextColor(),
            imgHieght: 64,
            onTap: () {
              _handleHangUp(close);
            },
          ),
          ExtendButton(
            imgUrl: "assets/images/switch_camera.png",
            tips: CallKit_t(" "),
            textColor: _getTextColor(),
            imgHieght: 42,
            onTap: () {
              _handleSwitchCamera();
            },
          ),
        ]),
      ],
    );
  }

  static Widget _buildVideoCallerAndCalleeAcceptedView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ExtendButton(
          imgUrl: "assets/images/switch2audio.png",
          imgHieght: 20,
          tips: CallKit_t("切到语音通话"),
          onTap: () {
            _switchToAudio();
          },
          textColor: _getTextColor(),
        ),
        const SizedBox(
          height: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ExtendButton(
              imgUrl: CallState.instance.isMicrophoneMute ? "assets/images/mute_on.png" : "assets/images/mute.png",
              tips: CallKit_t("麦克风"),
              textColor: _getTextColor(),
              imgHieght: 52,
              onTap: () {
                _handleSwitchMic();
              },
            ),
            ExtendButton(
              imgUrl: CallState.instance.audioDevice == TUIAudioPlaybackDevice.speakerphone
                  ? "assets/images/handsfree_on.png"
                  : "assets/images/handsfree.png",
              tips: CallState.instance.audioDevice == TUIAudioPlaybackDevice.speakerphone
                  ? CallKit_t("扬声器")
                  : CallKit_t("听筒"),
              textColor: _getTextColor(),
              imgHieght: 52,
              onTap: () {
                _handleSwitchAudioDevice();
              },
            ),
            ExtendButton(
              imgUrl: CallState.instance.isCameraOpen ? "assets/images/camera_on.png" : "assets/images/camera_off.png",
              tips: CallKit_t("摄像头"),
              textColor: _getTextColor(),
              imgHieght: 52,
              onTap: () {
                _handleOpenCloseCamera();
              },
            ),
          ],
        ),
        const SizedBox(
          height: 20,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          const SizedBox(
            width: 42,
          ),
          ExtendButton(
            imgUrl: "assets/images/hangup.png",
            tips: CallKit_t("挂断"),
            textColor: _getTextColor(),
            imgHieght: 64,
            onTap: () {
              _handleHangUp(close);
            },
          ),
          ExtendButton(
            imgUrl: "assets/images/switch_camera.png",
            tips: CallKit_t(" "),
            textColor: _getTextColor(),
            imgHieght: 42,
            onTap: () {
              _handleSwitchCamera();
            },
          ),
        ]),
      ],
    );
  }

  static Widget _buildAudioAndVideoCalleeWaitingView(Function close) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        CallState.instance.mediaType == TUICallMediaType.video
            ? ExtendButton(
                imgUrl: "assets/images/switch2audio.png",
                imgHieght: 20,
                tips: CallKit_t("切到语音通话"),
                onTap: () {
                  _switchToAudio();
                },
                textColor: _getTextColor(),
              )
            : const SizedBox(),
        const SizedBox(
          width: 20,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ExtendButton(
              imgUrl: "assets/images/hangup.png",
              tips: CallKit_t("挂断"),
              textColor: _getTextColor(),
              imgHieght: 64,
              onTap: () {
                _handleReject(close);
              },
            ),
            ExtendButton(
              imgUrl: "assets/images/dialing.png",
              tips: CallKit_t("接听"),
              textColor: _getTextColor(),
              imgHieght: 64,
              onTap: () {
                _handleAccept();
              },
            ),
          ],
        )
      ],
    );
  }

  static _handleSwitchMic() async {
    if (CallState.instance.isMicrophoneMute) {
      CallState.instance.isMicrophoneMute = false;
      await CallManager.instance.openMicrophone();
    } else {
      CallState.instance.isMicrophoneMute = true;
      await CallManager.instance.closeMicrophone();
    }
    eventBus.notify(setStateEvent);
  }

  static _handleSwitchAudioDevice() async {
    if (CallState.instance.audioDevice == TUIAudioPlaybackDevice.earpiece) {
      CallState.instance.audioDevice = TUIAudioPlaybackDevice.speakerphone;
    } else {
      CallState.instance.audioDevice = TUIAudioPlaybackDevice.earpiece;
    }
    await CallManager.instance.selectAudioPlaybackDevice(CallState.instance.audioDevice);
    eventBus.notify(setStateEvent);
  }

  static _handleHangUp(Function close) async {
    await CallManager.instance.hangup();
    close();
  }

  static _handleReject(Function close) async {
    await CallManager.instance.reject();
    close();
  }

  static _handleAccept() async {
    TUIPermissionResult permissionRequestResult = TUIPermissionResult.requesting;
    if (Platform.isAndroid) {
      permissionRequestResult = await PermissionRequest.checkCallingPermission(CallState.instance.mediaType);
    }
    if (permissionRequestResult == TUIPermissionResult.granted || Platform.isIOS) {
      await CallManager.instance.accept();
      CallState.instance.selfUser.callStatus = TUICallStatus.accept;
    } else {
      TUIToast.show(content: CallKit_t("新通话呼入，但因权限不足，无法接听。请确认摄像头/麦克风权限已开启。"));
    }
    eventBus.notify(setStateEvent);
  }

  static void _handleOpenCloseCamera() async {
    CallState.instance.isCameraOpen = !CallState.instance.isCameraOpen;
    if (CallState.instance.isCameraOpen) {
      await CallManager.instance.openCamera(CallState.instance.camera, CallState.instance.selfUser.viewID);
    } else {
      await CallManager.instance.closeCamera();
    }
    eventBus.notify(setStateEvent);
  }

  static void _handleSwitchCamera() async {
    if (TUICamera.front == CallState.instance.camera) {
      CallState.instance.camera = TUICamera.back;
    } else {
      CallState.instance.camera = TUICamera.front;
    }
    await CallManager.instance.switchCamera(CallState.instance.camera);
    eventBus.notify(setStateEvent);
  }

  static _switchToAudio() {
    CallManager.instance.switchCallMediaType(TUICallMediaType.audio);
    eventBus.notify(setStateEvent);
  }

  static Color _getTextColor() {
    return (TUICallMediaType.audio == CallState.instance.mediaType) ? Colors.black : Colors.white;
  }
}
