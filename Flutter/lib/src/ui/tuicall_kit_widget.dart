import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/extensions/trtc_logger.dart';
import 'package:tencent_calls_uikit/src/ui/widget/groupcall/group_call_widget.dart';
import 'package:tencent_calls_uikit/src/ui/widget/singlecall/single_call_widget.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';

class TUICallKitWidget extends StatefulWidget {
  final Function close;

  const TUICallKitWidget({Key? key, required this.close}) : super(key: key);

  @override
  State<TUICallKitWidget> createState() => _TUICallKitWidgetState();
}

class _TUICallKitWidgetState extends State<TUICallKitWidget> {
  ITUINotificationCallback? onCallEndCallBack;

  @override
  void initState() {
    super.initState();
    TRTCLogger.info('TUICallKitWidget initState');
    if (CallState.instance.selfUser.callStatus == TUICallStatus.none) {
      Future.microtask(() {
        widget.close();
      });
    }
    onCallEndCallBack = (arg) {
      if (mounted) {
        widget.close();
      }
    };
    TUICore.instance.registerEvent(setStateEventOnCallEnd, onCallEndCallBack);
    WakelockPlus.enable();
  }

  @override
  Widget build(BuildContext context) {
    CallKitI18nUtils.setLanguage(Localizations.localeOf(context));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
          resizeToAvoidBottomInset: false,
          body: (CallState.instance.scene == TUICallScene.singleCall)
              ? SingleCallWidget(
                  close: widget.close,
                )
              : GroupCallWidget(
                  close: widget.close,
                )),
    );
  }

  @override
  void dispose() {
    super.dispose();
    TRTCLogger.info('TUICallKitWidget dispose');
    TUICore.instance.unregisterEvent(setStateEventOnCallEnd, onCallEndCallBack);
    WakelockPlus.disable();
  }
}
