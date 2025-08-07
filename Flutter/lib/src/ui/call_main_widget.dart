import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_calls_uikit/src/call_define.dart';
import 'package:tencent_calls_uikit/src/impl/call_manager.dart';
import 'package:tencent_calls_uikit/src/impl/call_state.dart';
import 'package:tencent_calls_uikit/src/data/constants.dart';
import 'package:tencent_calls_uikit/src/extensions/trtc_logger.dart';
import 'package:tencent_calls_uikit/src/i18n/i18n_utils.dart';
import 'package:tencent_calls_uikit/src/ui/widget/calls/calls_widget.dart';
import 'package:tencent_cloud_uikit_core/tencent_cloud_uikit_core.dart';

class TUICallKitWidget extends StatefulWidget {
  final Function close;

  const TUICallKitWidget({Key? key, required this.close}) : super(key: key);

  @override
  State<TUICallKitWidget> createState() => _TUICallKitWidgetState();
}

class _TUICallKitWidgetState extends State<TUICallKitWidget> with WidgetsBindingObserver {
  ITUINotificationCallback? onCallEndCallBack;

  @override
  void initState() {
    super.initState();
    TRTCLogger.info('TUICallKitWidget initState');
    WidgetsBinding.instance.addObserver(this);
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      CallManager.instance.startForegroundService();
    }
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
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && CallState.instance.selfUser.callStatus != TUICallStatus.none) {
      CallManager.instance.startForegroundService();
    }
    super.didChangeAppLifecycleState(state);
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
          body: CallsWidget(close: widget.close),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    TRTCLogger.info('TUICallKitWidget dispose');
    WidgetsBinding.instance.removeObserver(this);
    TUICore.instance.unregisterEvent(setStateEventOnCallEnd, onCallEndCallBack);
    CallManager.instance.enableWakeLock(false);
  }
}
