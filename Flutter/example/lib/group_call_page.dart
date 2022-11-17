import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'dart:async';

import 'package:tuicall_kit_example/store.dart';
import 'package:tencent_calls_engine/tuicall_define.dart';

class GroupCallPageRoute extends StatelessWidget {
  UserInfo userInfo;
  TUICallKit callsUIKitPlugin;
  GroupCallPageRoute(
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
          child: GroupCallPage(
        callsUIKitPlugin: callsUIKitPlugin,
        userInfo: userInfo,
      )),
    );
  }
}

class GroupCallPage extends StatefulWidget {
  UserInfo userInfo;
  TUICallKit callsUIKitPlugin;
  GroupCallPage({required this.callsUIKitPlugin, required this.userInfo});

  @override
  State<GroupCallPage> createState() => _GroupCallPageState(
      callsUIKitPlugin: callsUIKitPlugin, userInfo: userInfo);
}

class _GroupCallPageState extends State<GroupCallPage> {
  UserInfo userInfo;
  TUICallKit callsUIKitPlugin;
  _GroupCallPageState({required this.callsUIKitPlugin, required this.userInfo});

  String groupId = "";
  String roomId = "";

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
          Padding(padding: EdgeInsets.only(left: 30)),
          Column(
            children: [
              Text(
                "NickName: ${userInfo.userName}",
                style: TextStyle(fontSize: 20.0),
              ),
              Padding(padding: EdgeInsets.only(top: 20)),
              Text(
                "UserId: ${userInfo.userId}",
                style: TextStyle(fontSize: 20.0),
              )
            ],
          )
        ]),
        Padding(padding: EdgeInsets.only(top: 150)),
        TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: "input GroupId"),
          onChanged: ((value) => groupId = value),
        ),
        Padding(padding: EdgeInsets.only(top: 10)),
        TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: "input RoomId"),
          onChanged: ((value) => roomId = value),
        ),
        Padding(padding: EdgeInsets.only(top: 20)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
                icon: Icon(Icons.call),
                label: Text("Voice Call", style: TextStyle(fontSize: 20.0)),
                onPressed: () {
                  /// 语音通话
                  ///
                }),
            Padding(padding: EdgeInsets.only(left: 50)),
            ElevatedButton.icon(
                icon: Icon(Icons.video_camera_front),
                label: Text("Video Call", style: TextStyle(fontSize: 20.0)),
                onPressed: () {
                  /// 视频通话
                  ///
                }),
          ],
        ),
        Padding(padding: EdgeInsets.only(top: 200)),
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

void groupViceCall(TUICallKit callsUIKitPlugin, String roomId, String groupId) {
  TUIRoomId obj = TUIRoomId(intRoomId: int.parse(roomId));
  callsUIKitPlugin.joinInGroupCall(obj, groupId, TUICallMediaType.audio);
}

void groupVideoCall(
    TUICallKit callsUIKitPlugin, String roomId, String groupId) {
  TUIRoomId obj = TUIRoomId(intRoomId: int.parse(roomId));
  callsUIKitPlugin.joinInGroupCall(obj, groupId, TUICallMediaType.video);
}
