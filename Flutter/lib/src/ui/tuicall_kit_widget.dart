import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/ui/widget/groupcall/group_call_widget.dart';
import 'package:tencent_calls_uikit/src/ui/widget/singlecall/single_call_widget.dart';
import 'package:tencent_calls_uikit/src/utils/event_bus.dart';

class TUICallKitWidget extends StatefulWidget {
  final Function close;

  const TUICallKitWidget({Key? key, required this.close}) : super(key: key);

  @override
  State<TUICallKitWidget> createState() => _TUICallKitWidgetState();
}

class _TUICallKitWidgetState extends State<TUICallKitWidget> {
  EventCallback? setSateCallBack;
  EventCallback? onCallEndCallBack;

  @override
  void initState() {
    super.initState();
    setSateCallBack = (arg) {
      if (mounted) {
        setState(() {});
      }
    };
    onCallEndCallBack = (arg) {
      if (mounted) {
        widget.close();
      }
    };
    eventBus.register(setStateEvent, setSateCallBack);
    eventBus.register(setStateEventOnCallEnd, onCallEndCallBack);
  }

  @override
  Widget build(BuildContext context) {
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
    eventBus.unregister(setStateEvent, setSateCallBack);
    eventBus.unregister(setStateEventOnCallEnd, onCallEndCallBack);
  }
}
