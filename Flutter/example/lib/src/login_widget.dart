import 'package:flutter/material.dart';
import 'package:tuicall_kit_example/generate/app_localizations.dart';
import 'package:tencent_calls_uikit/tencent_calls_uikit.dart';
import 'package:tencent_cloud_chat_sdk/tencent_im_sdk_plugin.dart';
import 'package:tencent_cloud_chat_push/tencent_cloud_chat_push.dart';
import 'package:tuicall_kit_example/debug/generate_test_user_sig.dart';
import 'package:tuicall_kit_example/observer_functions.dart';
import 'package:tuicall_kit_example/src/main_widget.dart';
import 'package:tuicall_kit_example/src/profile_widget.dart';
import 'package:tuicall_kit_example/src/settings/settings_config.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key}) : super(key: key);

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  var _userId = '';

  bool _isButtonEnabled = true;

  @override
  void initState() {
    super.initState();
    TencentCloudChatPush().registerOnAppWakeUpEvent(onAppWakeUpEvent: () async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _userId = prefs.getString("userId")!;
      _login();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            _getAppInfoWidget(),
            _getLoginWidget(),
            _getQuickAccessWidget()
          ],
        ),
      ),
    );
  }

  _getAppInfoWidget() {
    return Positioned(
        left: 0,
        top: MediaQuery.of(context).size.height / 6,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'images/qcloudlog.png',
                  width: 70,
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    SizedBox(
                        width: _calculateTextWidth(AppLocalizations.of(context)!.trtc,
                                    const TextStyle(fontSize: 32)) >
                                (MediaQuery.of(context).size.width - 70 - 10)
                            ? _calculateTextWidth(AppLocalizations.of(context)!.trtc,
                                    const TextStyle(fontSize: 32)) /
                                2
                            : _calculateTextWidth(
                                AppLocalizations.of(context)!.trtc, const TextStyle(fontSize: 32)),
                        child: Text(
                          AppLocalizations.of(context)!.trtc,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 30,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        ))
                  ],
                )
              ],
            ),
          ],
        ));
  }

  _getLoginWidget() {
    return Positioned(
        left: 0,
        top: MediaQuery.of(context).size.height * 2 / 5,
        width: MediaQuery.of(context).size.width,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: MediaQuery.of(context).size.width - 60,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                Text(
                  AppLocalizations.of(context)!.user_id,
                  style: const TextStyle(
                      fontSize: 16, fontStyle: FontStyle.normal, color: Colors.black),
                ),
                const SizedBox(width: 10),
                SizedBox(
                    width: MediaQuery.of(context).size.width - 160,
                    child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.enter_user_id,
                          border: InputBorder.none,
                          labelStyle: const TextStyle(fontSize: 16),
                        ),
                        onChanged: ((value) => _userId = value)))
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 52,
            width: MediaQuery.of(context).size.width - 60,
            child: ElevatedButton(
              onPressed: () => _isButtonEnabled ? _login() : null,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(const Color(0xff056DF6)),
                shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              ),
              child: Text(
                AppLocalizations.of(context)!.login,
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
              ),
            ),
          )
        ]));
  }

  _getQuickAccessWidget() {
    return Positioned(
        left: 0,
        bottom: 54,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width / 3 - 10,
                  height: 1,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  AppLocalizations.of(context)!.quick_access,
                  style: const TextStyle(
                      fontSize: 16, fontStyle: FontStyle.normal, color: Colors.black),
                ),
                const SizedBox(width: 5),
                Container(
                  width: MediaQuery.of(context).size.width / 3 - 10,
                  height: 1,
                  decoration: const BoxDecoration(
                    color: Colors.grey,
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const SizedBox(width: 1),
                InkWell(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width / 4 - 20,
                    child: Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      AppLocalizations.of(context)!.package_purchase,
                      style: const TextStyle(fontSize: 14, color: Color(0xff056DF6)),
                    ),
                  ),
                  onTap: () => _lanuchURL(0),
                ),
                InkWell(
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width / 4 - 20,
                      child: Text(
                        AppLocalizations.of(context)!.integration,
                        style: const TextStyle(fontSize: 14, color: Color(0xff056DF6)),
                      )),
                  onTap: () => _lanuchURL(1),
                ),
                InkWell(
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width / 4 - 20,
                      child: Text(
                        AppLocalizations.of(context)!.api_docs,
                        style: const TextStyle(fontSize: 14, color: Color(0xff056DF6)),
                      )),
                  onTap: () => _lanuchURL(2),
                ),
                InkWell(
                  child: SizedBox(
                      width: MediaQuery.of(context).size.width / 4 - 20,
                      child: Text(
                        AppLocalizations.of(context)!.common_problems,
                        style: const TextStyle(fontSize: 14, color: Color(0xff056DF6)),
                      )),
                  onTap: () => _lanuchURL(3),
                ),
                const SizedBox(width: 1),
              ],
            ),
          ],
        ));
  }

  _lanuchURL(int index) async {
    String url =
        'https://cloud.tencent.com/document/product/647/78742#:~:text=%E6%89%80%E9%9C%80%E5%8A%9F%E8%83%BD%EF%BC%8C%E5%8D%95%E5%87%BB-,%E5%89%8D%E5%BE%80%E8%B4%AD%E4%B9%B0,-%E8%B4%AD%E4%B9%B0%E6%AD%A3%E5%BC%8F%E7%89%88';
    switch (index) {
      case 0:
        {
          url =
              'https://cloud.tencent.com/document/product/647/78742#:~:text=%E6%89%80%E9%9C%80%E5%8A%9F%E8%83%BD%EF%BC%8C%E5%8D%95%E5%87%BB-,%E5%89%8D%E5%BE%80%E8%B4%AD%E4%B9%B0,-%E8%B4%AD%E4%B9%B0%E6%AD%A3%E5%BC%8F%E7%89%88';
          break;
        }
      case 1:
        {
          url = 'https://cloud.tencent.com/document/product/647/82985';
          break;
        }
      case 2:
        {
          url = 'https://cloud.tencent.com/document/product/647/83052';
          break;
        }
      case 3:
        {
          url = 'https://cloud.tencent.com/document/product/647/84493';
          break;
        }
    }

    if (!await launchUrl(Uri.parse(url))) {}
  }

  _login() async {
    _isButtonEnabled = false;
    final result = await TUICallKit.instance
        .login(GenerateTestUserSig.sdkAppId, _userId, GenerateTestUserSig.genTestSig(_userId));
    if (result.code.isEmpty) {
      SettingsConfig.showBlurBackground = true;
      TUICallKit.instance.enableVirtualBackground(SettingsConfig.showBlurBackground);
      SettingsConfig.showIncomingBanner = true;
      TUICallKit.instance.enableIncomingBanner(SettingsConfig.showIncomingBanner);
      SettingsConfig.enableFloatWindow = true;
      TUICallKit.instance.enableFloatWindow(SettingsConfig.enableFloatWindow);

      setObserverFunction(callsEnginePlugin: TUICallEngine.instance);
      SettingsConfig.userId = _userId;
      final imInfo = await TencentImSDKPlugin.v2TIMManager.getUsersInfo(userIDList: [_userId]);
      SettingsConfig.nickname = imInfo.data?[0].nickName ?? "";
      SettingsConfig.avatar = imInfo.data?[0].faceUrl ?? "";
      if (SettingsConfig.nickname.isEmpty || SettingsConfig.avatar.isEmpty) {
        _enterProfileWidget();
      } else {
        _enterMainWidget();
      }
    }
    _isButtonEnabled = true;
  }

  _enterProfileWidget() {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
      builder: (context) {
        return const ProfileWidget();
      },
    ), (route) => false);
  }

  _enterMainWidget() {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
      builder: (context) {
        return const MainWidget();
      },
    ), (route) => false);
  }

  double _calculateTextWidth(String text, TextStyle textStyle) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }
}
