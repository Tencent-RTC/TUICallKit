import 'package:flutter/material.dart';
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
    return Text(
      _formatCallTime(),
      style: const TextStyle(color: Colors.white, fontSize: 14),
    );
  }

  @override
  void dispose() {
    super.dispose();
    eventBus.unregister(setStateEventRefreshTiming, refreshTimingCallBack);
  }

  String _formatCallTime() {
    int hour = CallState.instance.timeCount ~/ 3600;
    String hourShow = hour <= 9 ? "0$hour" : "$hour";
    int minute = (CallState.instance.timeCount % 3600) ~/ 60;
    String minuteShow = minute <= 9 ? "0$minute" : "$minute";
    int second = CallState.instance.timeCount % 60;
    String secondShow = second <= 9 ? "0$second" : "$second";
    return hour > 0 ? "$hourShow:$minuteShow:$secondShow" : "$minuteShow:$secondShow";
  }
}
