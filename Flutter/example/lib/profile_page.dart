import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'dart:async';
import 'package:tuicall_kit_example/call_page.dart';
import 'package:tuicall_kit_example/store.dart';
import 'package:tencent_calls_engine/tuicall_define.dart';

import 'debug/generate_test_user_sig.dart';

class ProfileRoute extends StatelessWidget {
  TUICallKit callsUIKitPlugin;
  UserInfo userInfo;
  ProfileRoute(
      {super.key, required this.callsUIKitPlugin, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            /// 登出
            userLogout(callsUIKitPlugin);

            /// 返回上一页
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Plugin example app'),
      ),
      body: Center(
          child: ProfilePage(
              callsUIKitPlugin: callsUIKitPlugin, userInfo: userInfo)),
    );
  }
}

class ProfilePage extends StatefulWidget {
  TUICallKit callsUIKitPlugin;
  UserInfo userInfo;
  ProfilePage(
      {Key? key, required this.callsUIKitPlugin, required this.userInfo})
      : super(key: key);

  @override
  _ProfilePageState createState() =>
      _ProfilePageState(callsUIKitPlugin: callsUIKitPlugin, userInfo: userInfo);
}

class _ProfilePageState extends State<ProfilePage> {
  TUICallKit callsUIKitPlugin;
  UserInfo userInfo;
  _ProfilePageState(
      {Key? key, required this.callsUIKitPlugin, required this.userInfo});

  String notesText =
      "Notes: TUICallKit support offline calling and multiple platforms such as Android,iOS,Web,Flutter etc.";

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(40),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image(
              image: AssetImage("images/qcloudlog.png"),
              width: 80,
            ),
            Padding(padding: EdgeInsets.only(left: 30)),
            Text(
              "TUICallKit",
              style: TextStyle(fontSize: 30.0),
            ),
          ],
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 100)),
        Text(
          "Set Your Name",
          style: TextStyle(fontSize: 15.0),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        TextField(
          autofocus: true,
          decoration: InputDecoration(hintText: "Input your userName"),
          onChanged: ((value) => userInfo.userName = value),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 20)),
        ElevatedButton(
          onPressed: () async {
            if (!userInfo.userName.isEmpty) {
              /// 用户注册登陆
              TUIResult result = await setUserInfo(callsUIKitPlugin, userInfo);
              if (result.code.isEmpty) {
                ///页面跳转
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return CallPageRoute(
                        callsUIKitPlugin: callsUIKitPlugin, userInfo: userInfo);
                  },
                ));
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Set Fail！"),
                      content: Text(
                          "result.code:${result.code}, result.message: ${result.message}？"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text("确定"),
                        ),
                      ],
                    );
                  },
                );
              }
            }
          },
          child: Text("Login"),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 50),
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 100)),
        Text(
          notesText,
          style: TextStyle(fontSize: 12.0),
        ),
        Padding(padding: EdgeInsets.only(top: 10)),
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

Future<TUIResult> setUserInfo(
    TUICallKit callsUIKitPlugin, UserInfo userInfo) async {
  /// 设置用户信息
  return await callsUIKitPlugin.setSelfInfo(
      userInfo.userName, userInfo.userAvatar);
}
