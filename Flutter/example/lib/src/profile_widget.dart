import 'dart:math';
import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tuicall_kit_example/src/main_widget.dart';
import 'package:tuicall_kit_example/src/settings/settings_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfileWidget extends StatefulWidget {
  const ProfileWidget({Key? key}) : super(key: key);

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  bool _isButtonEnabled = true;
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child:Scaffold(
            resizeToAvoidBottomInset: false,
            body: SizedBox(
              width: MediaQuery
                  .of(context)
                  .size
                  .width,
              child: Stack(
                children: [
                  _getAppInfoWidget(),
                  _getSetInfoWidget(),
                  _getBottomWidget()
                ],
              ),
            ))
    );
  }

  _getAppInfoWidget() {
    return Positioned(
        left: 0,
        top: MediaQuery
            .of(context)
            .size
            .height / 6,
        width: MediaQuery
            .of(context)
            .size
            .width,
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
                        width: _calculateTextWidth(
                            AppLocalizations.of(context)!.trtc, const TextStyle(
                            fontSize: 32)) > (MediaQuery
                            .of(context)
                            .size
                            .width - 70 - 10) ?
                        _calculateTextWidth(
                            AppLocalizations.of(context)!.trtc, const TextStyle(
                            fontSize: 32)) / 2 :
                        _calculateTextWidth(
                            AppLocalizations.of(context)!.trtc, const TextStyle(
                            fontSize: 32)),
                        child: Text(
                          AppLocalizations.of(context)!.trtc,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 32,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.w400,
                              color: Colors.black),
                        )
                    )
                  ],
                )
              ],
            ),
          ],
        ));
  }

  _getSetInfoWidget() {
    return Positioned(
        left: 0,
        top: MediaQuery
            .of(context)
            .size
            .height * 2 / 5,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Column(
          children: [

            Container(
              width: MediaQuery
                  .of(context)
                  .size
                  .width - 60,
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
                    AppLocalizations.of(context)!.nick_name,
                    style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.normal,
                        color: Colors.black),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width - 200,
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintStyle: const TextStyle(fontSize: 16),
                        hintText: AppLocalizations.of(context)!.enter_nickname,
                        border: InputBorder.none,
                        labelStyle: const TextStyle(fontSize: 16),
                      ),
                      onChanged: ((value) =>
                      SettingsConfig.nickname = value),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              height: 52,
              width: MediaQuery
                  .of(context)
                  .size
                  .width - 60,
              child:
              ElevatedButton(
                onPressed: () => _isButtonEnabled ? _setUserInfo() : null,
                style: ButtonStyle(
                  backgroundColor:
                  MaterialStateProperty.all(const Color(0xff056DF6)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
                ),
                child: Text(AppLocalizations.of(context)!.confirm
                ),
              ),
            )

          ],
        )
    );
  }

  _getBottomWidget() {
    return Positioned(
      left: 0,
      bottom: 20,
      width: MediaQuery
          .of(context)
          .size
          .width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Image(
            image: AssetImage("images/qcloudlog.png"),
            width: 20,
          ),
          const Padding(padding: EdgeInsets.only(left: 10)),
          Text(
            AppLocalizations.of(context)!.tencent_cloud,
            style: const TextStyle(fontSize: 15.0),
          ),
        ],
      ),
    );
  }

  double _calculateTextWidth(String text, TextStyle textStyle) {
    TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: textStyle),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }

  _setUserInfo() async {
    _isButtonEnabled = false;
    if (SettingsConfig.nickname.isNotEmpty) {
      int index = Random().nextInt(_userAvatarArray.length);
      SettingsConfig.avatar = _userAvatarArray[index];
      TUIResult result = await TUICallKit.instance.setSelfInfo(
          SettingsConfig.nickname, SettingsConfig.avatar);

      if (result.code.isEmpty) {
        _enterMainWidget();
      } else {
        _showDialog(result);
      }
    }
    _isButtonEnabled = true;
  }

  _enterMainWidget() {
    Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(
      builder: (context) {
        return const MainWidget();
      },
    ), (route) => false);
  }

  _showDialog(TUIResult result) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.login_fail),
          content: Text(
              "result.code:${result.code}, result.message: ${result
                  .message}？"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(AppLocalizations.of(context)!.next),
            ),
          ],
        );
      },
    );
  }

  final List<String> _userAvatarArray = [
    "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar1.png",
    "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar2.png",
    "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar3.png",
    "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar4.png",
    "https://liteav.sdk.qcloud.com/app/res/picture/voiceroom/avatar/user_avatar5.png",
  ];
}
