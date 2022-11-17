import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'dart:async';

import 'package:tuicall_kit_example/group_call_page.dart';
import 'package:tuicall_kit_example/store.dart';
import 'package:tencent_calls_engine/tuicall_define.dart';

class CallPageRoute extends StatelessWidget {
  UserInfo userInfo;
  TUICallKit callsUIKitPlugin;
  CallPageRoute(
      {super.key, required this.callsUIKitPlugin, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            /// 返回上一页
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Plugin example app'),
      ),
      body: Center(
          child:
              CallPage(callsUIKitPlugin: callsUIKitPlugin, userInfo: userInfo)),
    );
  }
}

class CallPage extends StatefulWidget {
  UserInfo userInfo;
  TUICallKit callsUIKitPlugin;
  CallPage({required this.callsUIKitPlugin, required this.userInfo});

  @override
  State<CallPage> createState() =>
      _CallPageState(callsUIKitPlugin: callsUIKitPlugin, userInfo: userInfo);
}

class _CallPageState extends State<CallPage> {
  UserInfo userInfo;
  TUICallKit callsUIKitPlugin;
  _CallPageState({required this.callsUIKitPlugin, required this.userInfo});

  String callUserId = "";
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        Padding(padding: EdgeInsets.only(top: 100)),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image(
            image: NetworkImage(userInfo.userAvatar),
            width: 80,
          ),
          Padding(padding: EdgeInsets.only(left: 20)),
          Column(
            children: [
              Text(
                "NickName: ${userInfo.userName}",
                style: TextStyle(fontSize: 20.0),
              ),
              Padding(padding: EdgeInsets.only(top: 40)),
              Text(
                "UserId: ${userInfo.userId}",
                style: TextStyle(fontSize: 20.0),
              )
            ],
          )
        ]),
        Padding(padding: EdgeInsets.symmetric(vertical: 100)),
        TextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(hintText: "Enter the uderId to call"),
          onChanged: ((value) => callUserId = value),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
                icon: Icon(Icons.call),
                label: Text("Voice Call", style: TextStyle(fontSize: 20.0)),
                onPressed: () {
                  if (!callUserId.isEmpty) {
                    /// 语音通话
                    voiceCall(callsUIKitPlugin, callUserId);
                  }
                }),
            Padding(padding: EdgeInsets.only(left: 50)),
            ElevatedButton.icon(
                icon: Icon(Icons.video_camera_front),
                label: Text("Video Call", style: TextStyle(fontSize: 20.0)),
                onPressed: () {
                  if (!callUserId.isEmpty) {
                    /// 视频通话
                    videoCall(callsUIKitPlugin, callUserId);
                  }
                }),
          ],
        ),
        Padding(padding: EdgeInsets.only(top: 200)),
        TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return GroupCallPageRoute(
                    callsUIKitPlugin: callsUIKitPlugin, userInfo: userInfo);
              },
            ));
          },
          child: Text("Going Group Calls", style: TextStyle(fontSize: 20.0)),
        ),
        Padding(padding: EdgeInsets.only(top: 50)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("images/qcloudlog.png"),
              width: 20,
            ),
            Padding(padding: EdgeInsets.only(left: 10)),
            Text(
              "Tencent Cloud",
              style: TextStyle(fontSize: 15.0),
            ),
          ],
        ),
      ],
    );
  }
}

void voiceCall(TUICallKit callsUIKitPlugin, String callUserId) {
  callsUIKitPlugin.call(callUserId, TUICallMediaType.audio);
}

void videoCall(TUICallKit callsUIKitPlugin, String callUserId) {
  callsUIKitPlugin.call(callUserId, TUICallMediaType.video);
}

void userLogout(TUICallKit callsUIKitPlugin) {
  callsUIKitPlugin.logout();
}
