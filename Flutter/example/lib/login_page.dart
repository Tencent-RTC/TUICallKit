import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'package:tencent_calls_engine/tuicall_define.dart';
import 'package:tencent_calls_engine/tuicall_engine.dart';
import 'package:tuicall_kit_example/i18n/i18n_utils.dart';
import 'package:tuicall_kit_example/store.dart';
import 'package:tuicall_kit_example/profile_page.dart';
import 'debug/generate_test_user_sig.dart';
import 'observer_functions.dart';

class LoginPageRoute extends StatelessWidget {
  TUICallKit callsUIKitPlugin;
  UserInfo userInfo;
  LoginPageRoute(
      {super.key, required this.callsUIKitPlugin, required this.userInfo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(TIM_t("TUICallKit 示例工程")),
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

  String appIntrduceText = TIM_t("TUICallKit是腾讯云推出的音视频通话UI组件。");
  String functionIntrduceText = TIM_t("集成这个组件，写几行代码就可以使用视频通话功能。");
  String notesText = TIM_t("注意：TUICallKit支持离线调用，支持Android、iOS、Web、Flutter等多平台");

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
          appIntrduceText,
          style: TextStyle(fontSize: 15.0),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        Text(
          functionIntrduceText,
          style: TextStyle(fontSize: 15.0),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 10)),
        TextField(
          autofocus: true,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(hintText: TIM_t("输入User ID")),
          onChanged: ((value) => userInfo.userId = value),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 20)),
        ElevatedButton(
          onPressed: () async {
            if (!userInfo.userId.isEmpty) {
              /// 用户注册登陆
              TUIResult result = await userLogin(callsUIKitPlugin, userInfo);
              if (result.code.isEmpty) {
                /// 注册回调函数
                setObserverFubction(callsEnginePlugin: TUICallEngine.instance);
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
                      title: Text(TIM_t("登录失败")),
                      content: Text(
                          "result.code:${result.code}, result.message: ${result.message}？"),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text(TIM_t("继续")),
                        ),
                      ],
                    );
                  },
                );
              }
            }
          },
          child: Text(TIM_t("登录")),
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(100, 50),
          ),
        ),
        Padding(padding: EdgeInsets.symmetric(vertical: 100)),
        Text(
          notesText,
          textAlign: TextAlign.center,
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
              TIM_t("腾讯云"),
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
