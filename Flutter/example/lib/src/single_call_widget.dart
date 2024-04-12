import 'package:flutter/material.dart';
import 'package:tencent_calls_uikit/tuicall_kit.dart';
import 'package:tencent_calls_engine/tencent_calls_engine.dart';
import 'package:tuicall_kit_example/src/settings/settings_config.dart';
import 'package:tuicall_kit_example/src/settings/settings_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class SingleCallWidget extends StatefulWidget {
  const SingleCallWidget({Key? key}) : super(key: key);

  @override
  State<SingleCallWidget> createState() => _SingleCallWidgetState();
}

class _SingleCallWidgetState extends State<SingleCallWidget> {
  String _calledUserId = '';
  bool _isAudioCall = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.single_call),
        leading: IconButton(
            onPressed: () => _goBack(),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            )),
      ),
      body: Stack(
        children: [_getCallParamsWidget(), _getBtnWidget()],
      ),
    );
  }

  _getCallParamsWidget() {
    return Positioned(
        top: 38,
        left: 10,
        width: MediaQuery.of(context).size.width - 20,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.user_id,
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                SizedBox(
                    width: 200,
                    child: TextField(
                        autofocus: true,
                        textAlign: TextAlign.right,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.enter_callee_id,
                          border: InputBorder.none,
                        ),
                        onChanged: ((value) => _calledUserId = value)))
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.media_type,
                  style: const TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      color: Colors.black),
                ),
                Row(children: [
                  Row(
                    children: [
                      Checkbox(
                        value: !_isAudioCall,
                        onChanged: (value) {
                          setState(() {
                            _isAudioCall = !value!;
                          });
                        },
                        shape: const CircleBorder(),
                      ),
                      Text(
                        AppLocalizations.of(context)!.video_call,
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                      ),
                    ],
                  ),
                  const SizedBox(width: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _isAudioCall,
                        onChanged: (value) {
                          setState(() {
                            _isAudioCall = value!;
                          });
                        },
                        shape: const CircleBorder(),
                      ),
                      Text(
                        AppLocalizations.of(context)!.voice_call,
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ])
              ],
            ),
            const SizedBox(height: 45),
            InkWell(
              onTap: () => _goSettings(),
              child: Text(
                '${AppLocalizations.of(context)!.settings} >',
                style: const TextStyle(
                    fontSize: 16,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.bold,
                    color: Color(0xff056DF6)),
              ),
            )
          ],
        ));
  }

  _getBtnWidget() {
    return Positioned(
        left: 0,
        bottom: 50,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 60,
              width: MediaQuery.of(context).size.width * 5 / 6,
              child: ElevatedButton(
                  onPressed: () => _call(),
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(const Color(0xff056DF6)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.call),
                      const SizedBox(width: 10),
                      Text(
                        AppLocalizations.of(context)!.call,
                        style: const TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.normal,
                            fontWeight: FontWeight.normal,
                            color: Colors.white),
                      ),
                    ],
                  )),
            ),
          ],
        ));
  }

  _goBack() {
    Navigator.of(context).pop();
  }

  _call() {
    TUICallKit.instance.call(
        _calledUserId,
        _isAudioCall ? TUICallMediaType.audio : TUICallMediaType.video,
        _createTUICallParams());
  }

  TUICallParams _createTUICallParams() {
    TUICallParams params = TUICallParams();
    if (SettingsConfig.intRoomId != 0) {
      params.roomId = TUIRoomId.intRoomId(intRoomId: SettingsConfig.intRoomId);
    } else if (SettingsConfig.strRoomId.isNotEmpty) {
      params.roomId = TUIRoomId.strRoomId(strRoomId: SettingsConfig.strRoomId);
    }
    params.timeout = SettingsConfig.timeout;
    params.userData = SettingsConfig.extendInfo;

    if (SettingsConfig.offlinePushInfo == null || SettingsConfig.offlinePushInfo!.title == null ||
        SettingsConfig.offlinePushInfo!.title!.isEmpty) {
      TUIOfflinePushInfo offlinePushInfo = TUIOfflinePushInfo();
      offlinePushInfo.title = "Flutter TUICallKit";
      offlinePushInfo.desc = "This is an incoming call from Flutter TUICallkit";
      offlinePushInfo.ignoreIOSBadge = false;
      offlinePushInfo.iOSSound = "phone_ringing.mp3";
      offlinePushInfo.androidSound = "phone_ringing";
      offlinePushInfo.androidOPPOChannelID = "Flutter TUICallKit";
      offlinePushInfo.androidVIVOClassification = 1;
      offlinePushInfo.androidFCMChannelID = "fcm_push_channel";
      offlinePushInfo.androidHuaWeiCategory = "Flutter TUICallKit";
      offlinePushInfo.iOSPushType = TUICallIOSOfflinePushType.VoIP;
      params.offlinePushInfo = offlinePushInfo;
    } else {
      params.offlinePushInfo = SettingsConfig.offlinePushInfo;
    }
    return params;
  }

  _goSettings() {
    Navigator.push(context, MaterialPageRoute(
      builder: (context) {
        return const SettingsWidget();
      },
    ));
  }
}
