import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'package:tuicall_kit_example/src/group_call_widget.dart';
import 'package:tuicall_kit_example/src/settings/settings_config.dart';
import 'package:tuicall_kit_example/src/single_call_widget.dart';
import 'package:tuicall_kit_example/src/login_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainWidget extends StatefulWidget {
  const MainWidget({Key? key}) : super(key: key);

  @override
  State<MainWidget> createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
            resizeToAvoidBottomInset: false,
            body: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [_getUserInfo(), _getAppInfoWidget(), _getBtnWidget()],
              ),
            )));
  }

  _getUserInfo() {
    return Positioned(
        left: 10,
        top: 50,
        child: Row(
          children: [
            Container(
                width: 55,
                height: 55,
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(27.5)),
                ),
                child: InkWell(
                  child: Image(
                    image: NetworkImage(
                        SettingsConfig.avatar.isNotEmpty ? SettingsConfig.avatar : SettingsConfig.defaultAvatar),
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stackTrace) => Image.asset('images/people.webp'),
                  ),
                  onTap: () => _showDialog(),
                )),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                SettingsConfig.nickname,
                style: const TextStyle(fontSize: 14, fontStyle: FontStyle.normal, color: Colors.black),
              ),
              const SizedBox(height: 10),
              Text(
                'userId: ${SettingsConfig.userId}',
                style: const TextStyle(
                    fontSize: 12, fontStyle: FontStyle.normal, fontWeight: FontWeight.normal, color: Colors.black),
              )
            ])
          ],
        ));
  }

  _getAppInfoWidget() {
    return Positioned(
        left: 0,
        top: 151,
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
                SizedBox(
                    width: _calculateTextWidth(AppLocalizations.of(context)!.trtc, const TextStyle(fontSize: 32)) >
                            (MediaQuery.of(context).size.width - 70 - 10)
                        ? _calculateTextWidth(AppLocalizations.of(context)!.trtc, const TextStyle(fontSize: 32)) / 2
                        : _calculateTextWidth(AppLocalizations.of(context)!.trtc, const TextStyle(fontSize: 32)),
                    child: Text(
                      AppLocalizations.of(context)!.trtc,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 30, fontStyle: FontStyle.normal, fontWeight: FontWeight.w400, color: Colors.black),
                    ))
              ],
            ),
          ],
        ));
  }

  _getBtnWidget() {
    return Positioned(
        left: 0,
        bottom: 84,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 52,
              width: MediaQuery.of(context).size.width * 5 / 6,
              child: ElevatedButton(
                  onPressed: () => _goSingleCallWidget(),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color(0xff056DF6)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_outline_outlined),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.single_call,
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ],
                  )),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              width: MediaQuery.of(context).size.width * 5 / 6,
              child: ElevatedButton(
                  onPressed: () => _goGroupCallWidget(),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color(0xff056DF6)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.people_outline),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.group_call,
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.w500,
                            color: Colors.white),
                      ),
                    ],
                  )),
            )
          ],
        ));
  }

  _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(AppLocalizations.of(context)!.logout),
            actions: [
              CupertinoDialogAction(child: Text(AppLocalizations.of(context)!.cancel), onPressed: () => Navigator.of(context).pop()),
              CupertinoDialogAction(
                  child: Text(AppLocalizations.of(context)!.confirm),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _logout();
                  })
            ],
          );
        });
  }

  _logout() {
    TUICallKit.instance.logout();

    TUICallKit.navigatorObserver.navigator?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (widget) {
          return const LoginWidget();
        }), (route) => false);
  }

  _goSingleCallWidget() async {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const SingleCallWidget();
      },
    ));
  }

  _goGroupCallWidget() async {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const GroupCallWidget();
      },
    ));
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
