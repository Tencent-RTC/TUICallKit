import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'package:tencent_calls_engine/tuicall_define.dart';
import 'package:tuicall_kit_example/store.dart';
import 'package:tuicall_kit_example/profile_page.dart';
import 'debug/generate_test_user_sig.dart';

class LoginPageRoute extends StatelessWidget {
  TUICallKit callsUIKitPlugin;
  UserInfo userInfo;
  LoginPageRoute(
      {super.key, required this.callsUIKitPlugin, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: Center(
          child: LoginPage(
              callsUIKitPlugin: callsUIKitPlugin, userInfo: userInfo)),
    );
  }
}

class LoginPage extends StatefulWidget {
  TUICallKit callsUIKitPlugin;
  UserInfo userInfo;
  LoginPage({Key? key, required this.callsUIKitPlugin, required this.userInfo})
      : super(key: key);

  @override
  _LoginPageState createState() =>
      _LoginPageState(callsUIKitPlugin: callsUIKitPlugin, userInfo: userInfo);
}

class _LoginPageState extends State<LoginPage> {
  TUICallKit callsUIKitPlugin;
  UserInfo userInfo;
  _LoginPageState(
      {Key? key, required this.callsUIKitPlugin, required this.userInfo});

  String appIntrduceText =
      "TUICallKit is a UIKit about voice&video calls launched by Tencent Cloud.";
  String functionIntrduceText =
      "By integrating this component, you can write a few lines of code to use the video calling function.";
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
        Padding(padding: EdgeInsets.symmetric(vertical: 20)),
        Text(
          appIntrduceText,
          style: TextStyle(fontSize: 15.0),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        Text(
          functionIntrduceText,
          style: TextStyle(fontSize: 15.0),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 100)),
        TextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(hintText: "Input your userId"),
          onChanged: ((value) => userInfo.userId = value),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 20)),
        ElevatedButton(
          onPressed: () async {
            if (!userInfo.userId.isEmpty) {
              /// 用户注册登陆
              TUIResult result = await userLogin(callsUIKitPlugin, userInfo);
              if (result.code.isEmpty) {
                ///页面跳转
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) {
                    return ProfileRoute(
                        callsUIKitPlugin: callsUIKitPlugin, userInfo: userInfo);
                  },
                ));
              } else {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Login Fail！"),
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

Future<TUIResult> userLogin(
    TUICallKit callsUIKitPlugin, UserInfo userInfo) async {
  /// 登陆
  return await callsUIKitPlugin.login(
      sdkAppId: GenerateTestUserSig.sdkAppId,
      userId: userInfo.userId,
      userSig: GenerateTestUserSig.genTestSig(userInfo.userId));
}
