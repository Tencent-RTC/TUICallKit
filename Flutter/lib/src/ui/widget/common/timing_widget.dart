import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tencent_calls_uikit/src/call_state.dart';
import 'package:tencent_calls_uikit/src/utils/event_bus.dart';

class TimingWidget extends StatefulWidget {
  const TimingWidget({Key? key}) : super(key: key);

  @override
  State<TimingWidget> createState() => _TimingWidgetState();
}

class _TimingWidgetState extends State<TimingWidget> {
  EventCallback? refreshTimingCallBack;

  @override
  void initState() {
    super.initState();
    refreshTimingCallBack = (arg) {
      setState(() {});
    };
    eventBus.register(setStateEventRefreshTiming, refreshTimingCallBack);
  }

  @override
  Widget build(BuildContext context) {
    int hour = CallState.instance.timeCount ~/ 3600;
    int minute = (CallState.instance.timeCount % 3600) ~/ 60;
    int second = CallState.instance.timeCount % 60;
    return Text(
      hour > 0
          ? sprintf('%02d:%02d:%02d', [hour, minute, second])
          : sprintf('%02d:%02d', [minute, second]),
      style: (TUICallMediaType.audio == CallState.instance.mediaType)
          ? const TextStyle(color: Colors.black, fontSize: 14)
          : const TextStyle(color: Colors.white, fontSize: 14),
    );
  }

  @override
  void dispose() {
    super.dispose();
    eventBus.unregister(setStateEventRefreshTiming, refreshTimingCallBack);
  }
}
